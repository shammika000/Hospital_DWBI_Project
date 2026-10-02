using System.Text.Json.Nodes;
using Microsoft.AnalysisServices;
using Microsoft.AnalysisServices.Tabular;
using TomDatabase = Microsoft.AnalysisServices.Tabular.Database;
using TomServer = Microsoft.AnalysisServices.Tabular.Server;
using TomJson = Microsoft.AnalysisServices.Tabular.JsonSerializer;

var bimPath = args.Length > 0
    ? args[0]
    : @"e:\SLIIT\3rd year 1st sem\DWBI project\Hospital_DWBI_Project\03_SSAS\Hospital_Finance_SSAS\Hospital_Finance_SSAS\Model.bim";
var serverName = args.Length > 1 ? args[1] : @"LAPTOP-FJP15H44\SSASTABULAR";
var dbName = args.Length > 2 ? args[2] : "Hospital_Finance_SSAS";

Console.WriteLine($"BIM: {bimPath}");
Console.WriteLine($"Server: {serverName}");
Console.WriteLine($"Database: {dbName}");

using var server = new TomServer();
Console.WriteLine("Connecting...");
server.Connect($"Data Source={serverName};");
Console.WriteLine($"Connected. Name={server.Name} Edition={server.Edition} Version={server.Version} Mode={server.ServerMode}");

Console.WriteLine("Existing databases:");
foreach (TomDatabase existing in server.Databases)
{
    Console.WriteLine($"  - {existing.Name} ({existing.CompatibilityLevel})");
}

try
{
    var dbFromJson = TomJson.DeserializeDatabase(File.ReadAllText(bimPath), new DeserializeOptions { });
    dbFromJson.Name = dbName;
    dbFromJson.ID = dbName;
    foreach (var ds in dbFromJson.Model.DataSources.OfType<ProviderDataSource>())
    {
        ds.ImpersonationMode = Microsoft.AnalysisServices.Tabular.ImpersonationMode.ImpersonateServiceAccount;
        Console.WriteLine($"Provider data source {ds.Name} impersonation={ds.ImpersonationMode}");
    }
    Console.WriteLine($"Deserialized. Tables={dbFromJson.Model.Tables.Count} Compat={dbFromJson.CompatibilityLevel}");

    var existingDb = server.Databases.FindByName(dbName);
    if (existingDb is not null)
    {
        Console.WriteLine("Dropping existing database...");
        existingDb.Drop();
    }

    server.Databases.Add(dbFromJson);
    Console.WriteLine("Updating database on server...");
    dbFromJson.Update(UpdateOptions.ExpandFull);
    Console.WriteLine("Metadata deployed.");
}
catch (Exception ex)
{
    Console.WriteLine("TOM update failed: " + ex);
    Console.WriteLine("--- Falling back to Execute TMSL ---");
    var root = JsonNode.Parse(File.ReadAllText(bimPath))!.AsObject();
    root.Remove("id");
    root["name"] = dbName;
    var tmsl = new JsonObject
    {
        ["createOrReplace"] = new JsonObject
        {
            ["object"] = new JsonObject { ["database"] = dbName },
            ["database"] = root
        }
    };
    var json = tmsl.ToJsonString();
    try
    {
        var deployResult = server.Execute(json);
        WriteXmla(deployResult);
    }
    catch (Exception ex2)
    {
        Console.WriteLine("TMSL execute failed: " + ex2);
        return 1;
    }
}

server.Disconnect();
server.Connect($"Data Source={serverName};");
var db = server.Databases.FindByName(dbName);
if (db is null)
{
    Console.WriteLine("ERROR: Database was not created.");
    return 1;
}

Console.WriteLine("Processing (full refresh)...");
try
{
    db.Model.RequestRefresh(Microsoft.AnalysisServices.Tabular.RefreshType.Full);
    var save = db.Model.SaveChanges();
    Console.WriteLine($"SaveChanges Impact={save.Impact} XmlaNull={save.XmlaResults is null}");
    if (save.XmlaResults is not null)
    {
        WriteXmla(save.XmlaResults);
    }

    db = server.Databases.FindByName(dbName)!;
    db.Refresh();
    Console.WriteLine($"Database '{db.Name}' CompatibilityLevel={db.CompatibilityLevel} State={db.State} EstimatedSize={db.EstimatedSize}");
    foreach (var table in db.Model.Tables)
    {
        foreach (var part in table.Partitions)
        {
            Console.WriteLine($"  {table.Name}.{part.Name} State={part.State} Refreshed={part.RefreshedTime}");
        }
    }
}
catch (Exception ex)
{
    Console.WriteLine("Process failed (metadata may still be deployed): " + ex.Message);
    Console.WriteLine(ex);
    return 2;
}

return 0;

static void WriteXmla(XmlaResultCollection results)
{
    Console.WriteLine($"XMLA result count={results.Count} ContainsErrors={results.ContainsErrors}");
    foreach (XmlaResult result in results)
    {
        Console.WriteLine($"  Value={result.Value}");
        foreach (XmlaMessage message in result.Messages)
        {
            Console.WriteLine($"  {message.GetType().Name}: {message.Description}");
        }
    }
}
