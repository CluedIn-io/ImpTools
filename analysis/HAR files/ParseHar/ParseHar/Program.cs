using HarSharp;
using Newtonsoft.Json.Linq;

static void PrintUsage()
{
    Console.WriteLine("usage: ParseHar parse <file.har,...> or <wildcard.har>");
}

if (args.Length > 1)
{
    switch(args[0])
    {
        case "parse":
            var data = new List<string>();
            int retval = 0;
            {
                for(var i=1; retval == 0 && i<args.Length; i++)
                {
                    var file = args[1];
                    if (file.Contains('*'))
                    {
                        var fileArray = Directory.GetFiles(".", file);
                        Array.Sort(fileArray);
                        foreach (var matchedFile in fileArray)
                        {
                            retval = ParseHar(matchedFile, data);
                        }
                    }
                    else
                    {
                        retval = ParseHar(file, data);
                    }
                }
            }

            {
                // TODO: make configurable
                var output = new StreamWriter("results.json");
                output.WriteLine("[");
                bool first = true;
                var i = 0;
                foreach (var item in data)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        output.WriteLine(",");
                    }
                    output.WriteLine(item);
                    i++;
                }
                output.WriteLine("]");
                Console.WriteLine("Total entries written: {0}", i);
            }

            return retval;
    }
}

PrintUsage();
return -1;

static int ParseHar(string file, IList<string> data)
{
    int retval = -1;

    // https://github.com/giacomelli/HarSharp
    // https://github.com/w3c/web-performance/

    Console.WriteLine("Processing file {0}", file);

    var har = HarConvert.DeserializeFromFile(file);

    foreach (var entry in har.Log.Entries)
    {
        if (
            (entry.Request.Method == "POST") &&
            (entry.Request.Url.PathAndQuery == "/graphql")
           )
        {
            if (entry.Request.PostData.Text.Contains("getDataSetContent"))
            {
                if (entry.Response.Status == 200)
                {
                    Console.WriteLine("found getDataSetContent -> Content Size: {0}", entry.Response.Content.Size);

                    JObject contentJson = JObject.Parse(entry.Response.Content.Text);
#pragma warning disable CS8602 // Dereference of a possibly null reference.
                    IList<JToken> results = contentJson["data"]["inbound"]["dataSetContent"]["data"].Children().ToList();
#pragma warning restore CS8602 // Dereference of a possibly null reference.

                    int i = 0;
                    foreach (var result in results)
                    {
                        data.Add(result.ToString());
                        i++;
                    }
                    Console.WriteLine("... entries added {0}", i);
                }
            }
        }
    }

    return retval;
}
