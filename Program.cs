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
    static Assembly tool = Assembly.GetExecutingAssembly();
    static string  toolName = tool.GetName().Name;
    static string toolVersion = FileVersionInfo.GetVersionInfo(tool.Location).ProductVersion;
    static int width = 64;
    static Bash bash = new Bash();
    static string csproj;
    static string projectDir;
    static string destination;
    static string DllName;
    static string AppName;
    static string dotNetVersion;
    static string Here = AppDomain.CurrentDomain.BaseDirectory;

    static bool Verbose = false;
    static bool SkipRestore = false;
    static bool CustomAppName = false;
    static bool SelfContainedDeployment = false;
    static bool KeepTempFiles = false;

    static void Main(string[] args)
    {
        SayHello();
        ParseArgs(args);
        CheckPaths(args);
        FindCsproj(args[0]);
        SayTask($"{projectDir}/{csproj}", $"{destination}/{AppName}");
        if (!SkipRestore) RestoreProject();
        ComileProject();
        TransferFiles();
        RunAppImageTool();
        if (!KeepTempFiles) DeleteTempFiles();
        SayFinished($"New AppImage created at {destination}/{AppName}");
        SayBye();
    }

    static void CheckPaths(string[] args)
    {
        if (args.Length < 2 || !Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError("You must specify a valid .NET project AND destination folder.", 1);
        if (Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError($"{args[1]} is not a valid folder", 2);
        if (!Directory.Exists(args[0]) && Directory.Exists(args[1]))
            ExitWithError($"{args[0]} is not a valid folder", 3);
        
        projectDir = ConsolidatePath(args[0]);
        destination = ConsolidatePath(args[1]);
    }

    static void ParseArgs(string[] args)
    {
        if (args == null || args.Length == 0)
            HelpMenu();

        for (int i = 0; i < args.Length; i++)
        {
            if (args[i] == "-v" || args[i] == "--verbose")
            {
                Verbose = true;
            }
            else if (args[i] == "-c" || args[i] == "--compile")
            {
                SkipRestore = true;
            }
            else if (args[i] == "-n" || args[i] == "--name")
            {
                CustomAppName = true;
                AppName = args[i + 1];
            }
            else if (args[i] == "-s" || args[i] == "--scd")
            {
                SelfContainedDeployment = true;
            }
            else if (args[i] == "-k" || args[i] == "--keep")
            {
                KeepTempFiles = true;
            }
            else if (args[i] == "-h" || args[i] == "--help")
            {
                HelpMenu();
            }
        }
    }

    static void FindCsproj(string project)
    {
        bash.Command($"find {project} -maxdepth 1 -name '*.csproj'", redirect: true);
        var location = bash.Output.Split("\n", StringSplitOptions.RemoveEmptyEntries);

        if (location.Length < 1)
            ExitWithError($"No .csproj found in {project}", 10);
        if (location.Length > 1)
            ExitWithError($"More than one .csproj found in {project}", 11);
        
        var output = location[0].Split('/');
        csproj = output[output.Length - 1];
        dotNetVersion = GetCoreVersion();
        var split = csproj.Split('.');
        DllName = string.Join('.', split.Take(split.Length - 1));

        if (!CustomAppName)
            AppName = DllName;
    }

    static string GetCoreVersion()
    {
        var node = "/Project/PropertyGroup/TargetFramework";
        var xml = new XmlDocument();
        xml.LoadXml(File.ReadAllText(csproj));
        return xml.DocumentElement.SelectSingleNode(node).InnerText;
    }

    static void RestoreProject()
    {
        if (Verbose)
        {
            Console.WriteLine("Restoring .NET project dependencies... ");
            bash.Command($"cd {projectDir} && dotnet restore", redirect: false);
        }
        else
        {
            Console.Write("Restoring .NET project dependencies... ");
            bash.Command($"cd {projectDir} && dotnet restore", redirect: true);
        }
        
        CheckCommandOutput(errorCode: 20);
    }

    static void ComileProject()
    {
        string cmd;

        if (SelfContainedDeployment)
            cmd = $"cd {projectDir} && dotnet publish -c Release -r linux-x64";
        else 
            cmd = $"cd {projectDir} && dotnet publish -c Release";

        if (Verbose)
        {
            Console.WriteLine("Compiling .NET project... ");
            bash.Command(cmd, redirect: false);
        }
        else
        {
            Console.Write("Compiling .NET project... ");
            bash.Command(cmd, redirect: true);
        }
        
        CheckCommandOutput(errorCode: 21);
    }

    static void TransferFiles()
    {
        var path = $"{Here}/file-transfer.sh";
        string cmd;

        if (SelfContainedDeployment)
            cmd = $"{path} {projectDir} {DllName} {AppName} {dotNetVersion} true";
        else
            cmd = $"{path} {projectDir} {DllName} {AppName} {dotNetVersion}";
        
        
        Console.Write("Transferring Files... ");
        bash.Command(cmd, redirect: true);
        CheckCommandOutput(errorCode: 22);
    }

    static void RunAppImageTool()
    {
        var appimgtool = $"{Here}/appimagetool/AppRun";
        var cmd = $"{appimgtool} -n /tmp/{AppName}.temp {destination}/{AppName}";

        if (Verbose)
        {
            Console.WriteLine("Compressing with appimagetool... ");
            bash.Command(cmd, redirect: false);
        }
        else
        {
            Console.Write("Compressing with appimagetool... ");
            bash.Command(cmd, redirect: true);
        }
        
        CheckCommandOutput(errorCode: 23);
    }
    
    static void DeleteTempFiles()
    {
        Console.Write("Deleting temporary files... ");
        bash.Command($"rm -rf /tmp/{DllName}.temp");
        CheckCommandOutput(24);
    }

    static void SayFinished(string message)
    {
        Printer.WriteLine($"{Clr.Green}{message}{Clr.Default}");
    }

    static string ConsolidatePath(string path)
    {
        bash.Command($"cd {path} && dirs -0", redirect: true);
        var output = bash.Output.Split("\n", StringSplitOptions.RemoveEmptyEntries);
        return output[0];
    }

    static void SayHello()
    {
        var title = $" {toolName} {toolVersion} ";
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

    static void HelpMenu()
    {
        Printer.WriteLine(
            $"\n            {Frmt.Bold}{Clr.Cyan}Usage:{Reset.Code}\n"
            +  $"    ./netpkg-tool [Project Directory] [Destination] [Flags]\n\n"
            +  $"            {Frmt.Bold}{Clr.Cyan}Flags:{Reset.Code}\n"
            +  $"     --verbose or -v: Verbose output\n"
            +  $"     --compile or -c: Skip restoring dependencies\n"
            +  $"        --name or -n: Set ouput file to custom name\n"
            +  $"         --scd or -s: Self-Contained Deployment (SCD)\n"
            +  @"        --keep or -k: Keep /tmp/{AppName}.temp directory\n"
            +  $"        --help or -h: Help menu (this page)\n\n"
            +  $"    More information & source code available on github:\n"
            +  $"    https://github.com/phil-harmoniq/netpkg-tool\n"
            +  $"    Copyright (c) 2017 - MIT License\n"
        );
        SayBye();
        Environment.Exit(0);
    }
    
    static void SayBye()
    {
        Console.WriteLine(new String('-', width) + "\n");
    }

    static void SayTask(string project, string destination)
    {
        Clr.SetCyan();
        Console.WriteLine($"{project} -> {destination}");
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
