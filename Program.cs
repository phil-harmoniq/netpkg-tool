using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Reflection;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Shell.NET;
using ConsoleColors;

class Program
{
    static Assembly dll = Assembly.GetExecutingAssembly();
    static string  dllName = dll.GetName().Name;
    static string dllVersion = FileVersionInfo.GetVersionInfo(dll.Location).ProductVersion;
    static int width = 60;
    static Bash bash = new Bash();
    static string csproj;
    static string projectDir;
    static string destination;
    static string appName;
    static string coreVersion;

    static void Main(string[] args)
    {
        SayHello();

        if (args.Length < 2 || !Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError("You must specify a valid .NET project folder AND destination folder.", 1);
        if (Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError($"{args[1]} is not a valid folder", 2);
        if (!Directory.Exists(args[0]) && Directory.Exists(args[1]))
            ExitWithError($"{args[0]} is not a valid folder", 3);

        csproj = FindCsproj(args[0]);
        var split = csproj.Split('.');
        appName = string.Join('.', split.Take(split.Length - 1));
        projectDir = ConsolidatePath(args[0]);
        destination = ConsolidatePath(args[1]);
        coreVersion = GetCoreVersion();

        SayTask($"{projectDir}/{csproj}", $"{destination}/{appName}.npk");
        RestoreProject();
        ComileProject();
        TransferFiles();
        RunAppImageTool();
        SayBye();
    }

    static string FindCsproj(string project)
    {
        bash.Command($"realpath $(find {project} -maxdepth 1 -name '*.csproj')", redirect: true);
        var location = bash.Output.Split("\n", StringSplitOptions.RemoveEmptyEntries);

        if (location.Length < 1)
            ExitWithError($"No .csproj found in {project}", 10);
        if (location.Length > 1)
            ExitWithError($"More than one .csproj found in {project}", 11);
        
        var output = location[0].Split('/');
        return output[output.Length - 1];
    }

    static string GetCoreVersion()
    {
        var location = AbsolutePath($"{projectDir}/{csproj}");
        var node = "/Project/PropertyGroup/TargetFramework";
        var xml = new XmlDocument();
        xml.LoadXml(File.ReadAllText(location));
        return xml.DocumentElement.SelectSingleNode(node).InnerText;
    }

    static void RestoreProject()
    {
        Console.Write("Restoring .NET project dependencies... ");
        bash.Command($"cd {projectDir} && dotnet restore", redirect: true);
        CheckCommandOutput(errorCode: 20);
    }

    static void ComileProject()
    {
        Console.Write("Compiling .NET project... ");
        bash.Command($"cd {projectDir} && dotnet publish -c Release", redirect: true);
        CheckCommandOutput(errorCode: 21);
    }

    static void TransferFiles()
    {
        var path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "file-transfer.sh");
        Console.Write("Transferring Files... ");
        bash.Command($"{path} {projectDir} {appName} {coreVersion}", redirect: true);
        CheckCommandOutput(errorCode: 22);
    }

    static void RunAppImageTool()
    {
        Console.Write("Compressing with appimagetool... ");
        bash.Command($"appimagetool -n /tmp/{appName}.temp {destination}/{appName}.npk", redirect: true);
        CheckCommandOutput(errorCode: 23);
    }
    
    static void DeleteTempFiles()
    {
        Console.Write("Deleteing temporary files... ");
        bash.Command($"rm -rf /tmp/{appName}.temp");
        CheckCommandOutput(24);
    }

    static string ConsolidatePath(string path)
    {
        bash.Command($"cd {path} && dirs -0", redirect: true);
        var output = bash.Output.Split("\n", StringSplitOptions.RemoveEmptyEntries);
        return output[0];
    }

    static void SayHello()
    {
        var title = $" {dllName} {dllVersion} ";
        var newWidth = width - title.Length;
        var leftBar = new String('-', newWidth / 2);
        string rightBar;

        if (newWidth % 2 > 0)
            rightBar = new String('-', newWidth / 2 + 1);
        else
            rightBar = new String('-', newWidth / 2);
        
        Printer.WriteLine($"\n{leftBar}{Clr.Cyan}{Frmt.Bold}{title}{Reset.Code}{rightBar}");
    }
    
    static string AbsolutePath(string relativePath)
    {
        bash.Command($"readlink -f {relativePath}", redirect: true);
        var output = bash.Output.Split("\n", StringSplitOptions.RemoveEmptyEntries);
        return output[0];
    }
    
    static void SayBye()
    {
        Console.WriteLine(new String('-', width) + "\n");
    }

    static void SayTask(string project, string destination)
    {
        Clr.SetCyan();
        Console.WriteLine($"Compiling {project} to {destination}");
        Clr.SetDefault();
    }

    static void SayPass()
    {
        Printer.WriteLine($"{Frmt.Bold}[ {Clr.Green}PASS{Clr.Default} ]{Reset.Code}");
    }

    static void SayWarning()
    {
        Printer.WriteLine($"{Frmt.Bold}[ {Clr.Yellow}FAIL{Clr.Default} ]{Reset.Code}");
    }

    static void SayFail()
    {
        Printer.WriteLine($"{Frmt.Bold}[ {Clr.Red}FAIL{Clr.Default} ]{Reset.Code}");
    }

    static void ExitWithError(string message, int code)
    {
        Printer.WriteLine($"{Clr.Red}{message}{Clr.Default}");
        SayBye();
        Environment.Exit(code);
    }

    /// <param name="errorCode">Desired error code if the command didn't run properly</param>
    static void CheckCommandOutput(int errorCode = 1)
    {
        if (bash.ExitCode != 0)
        {
            SayFail();
            ExitWithError(bash.ErrorMsg, errorCode);
        }
        SayPass();
    }
}
