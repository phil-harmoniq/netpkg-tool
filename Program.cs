using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Reflection;
using System.Diagnostics;
using ConsoleColors;

class Program
{
    static Assembly tool = Assembly.GetExecutingAssembly();
    static string ToolName = tool.GetName().Name;
    static string ToolVersion = FileVersionInfo.GetVersionInfo(tool.Location).ProductVersion;
    static string Home = Environment.GetEnvironmentVariable("HOME");
    static string configDir = $"{Home}/.netpkg-tool";
    static int Width = 64;
    static Shell.NET.Bash Bash = new Shell.NET.Bash();
    static string Csproj;
    static string ProjectDir;
    static string Destination;
    static string DllName;
    static string AppName;
    static string DotNetVersion;
    static string Here = AppDomain.CurrentDomain.BaseDirectory;
    static string[] Args;

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
        SayTask(ProjectDir, $"{Destination}/{AppName}");
        if (!SkipRestore) RestoreProject();
        ComileProject();
        TransferFiles();
        RunAppImageTool();
        if (!KeepTempFiles) DeleteTempFiles();
        SayFinished($"New AppImage created at {Destination}/{AppName}");
        SayBye();
    }

    static void CheckPaths(string[] args)
    {
        if (args.Length < 2 || !Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError("You must specify a valid .NET project AND Destination folder.", 6);
        if (Directory.Exists(args[0]) && !Directory.Exists(args[1]))
            ExitWithError($"{args[1]} is not a valid folder", 7);
        if (!Directory.Exists(args[0]) && Directory.Exists(args[1]))
            ExitWithError($"{args[0]} is not a valid folder", 8);
        
        ProjectDir = GetRelativePath(args[0]);
        Destination = GetRelativePath(args[1]);
    }

    static void ParseArgs(string[] args)
    {
        Args = args;

        if (args == null || args.Length == 0)
            HelpMenu();
        
        if (args[0] == "--clear-log")
            ClearLogs();

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
        var location = Bash.Command($"find {project} -maxdepth 1 -name '*.csproj'", redirect: true).Lines;

        if (location == null || location[0] == "")
            ExitWithError($"No .csproj found in {GetRelativePath(project)}", 10);
        if (location.Length > 1)
            ExitWithError($"More than one .csproj found in {GetRelativePath(project)}", 11);
        
        var folderSplit = location[0].Split('/');
        Csproj = folderSplit[folderSplit.Length - 1];
        ProjectDir = GetRelativePath(project);
        DotNetVersion = GetCoreVersion();
        var nameSplit = Csproj.Split('.');
        DllName = string.Join('.', nameSplit.Take(nameSplit.Length - 1));

        if (!CustomAppName)
            AppName = DllName;
        
        if (SingleRuntimeIdentifier() && !SelfContainedDeployment)
        {
            SelfContainedDeployment = true;
            Printer.WriteLine(
                $"{Clr.Yellow}Caution: runtime identifier detected. Making self-contained app.{Clr.Default}");
        }
    }

    static string GetCoreVersion()
    {
        var path = GetAbsolutePath($"{ProjectDir}/{Csproj}");
        var node = "/Project/PropertyGroup/TargetFramework";
        var xml = new XmlDocument();
        xml.LoadXml(File.ReadAllText(path));
        return xml.DocumentElement.SelectSingleNode(node).InnerText;
    }

    static bool SingleRuntimeIdentifier()
    {
        var path = GetAbsolutePath($"{ProjectDir}/{Csproj}");
        var node = "/Project/PropertyGroup/RuntimeIdentifier";
        var xml = new XmlDocument();
        xml.LoadXml(File.ReadAllText(path));
        return xml.DocumentElement.SelectSingleNode(node) != null;
    }

    static void RestoreProject()
    {
        if (Verbose)
        {
            Console.WriteLine("Restoring .NET Core project dependencies...");
            Bash.Command($"cd {ProjectDir} && dotnet restore", redirect: false);
        }
        else
        {
            Console.Write("Restoring .NET Core project dependencies...");
            Bash.Command($"cd {ProjectDir} && dotnet restore", redirect: true);
        }
        
        CheckCommandOutput(errorCode: 20);
    }

    static void ComileProject()
    {
        string cmd;

        if (SelfContainedDeployment)
            cmd = $"cd {ProjectDir} && dotnet publish -c Release -r linux-x64 --no-restore";
        else 
            cmd = $"cd {ProjectDir} && dotnet publish -c Release --no-restore";

        if (Verbose)
        {
            Console.WriteLine("Compiling .NET Core project...");
            Bash.Command(cmd, redirect: false);
        }
        else
        {
            Console.Write("Compiling .NET Core project...");
            Bash.Command(cmd, redirect: true);
        }
        
        CheckCommandOutput(errorCode: 21);
    }

    static void TransferFiles()
    {
        var path = $"{Here}/file-transfer.sh";
        string cmd;

        if (SelfContainedDeployment)
            cmd = $"{path} {ProjectDir} {DllName} {AppName} {DotNetVersion} {ToolVersion} true";
        else
            cmd = $"{path} {ProjectDir} {DllName} {AppName} {DotNetVersion} {ToolVersion}";
        
        Console.Write($"Creating app directory at /tmp/{AppName}.temp...");
        Bash.Command(cmd, redirect: true);
        CheckCommandOutput(errorCode: 22);
    }

    static void RunAppImageTool()
    {
        var appimgtool = $"{Here}/appimagetool/AppRun";
        var cmd = $"{appimgtool} -n /tmp/{AppName}.temp {Destination}/{AppName}";

        if (Verbose)
        {
            Console.WriteLine($"Compressing app directory into an AppImage...");
            Bash.Command(cmd, redirect: false);
        }
        else
        {
            Console.Write($"Compressing app directory into an AppImage...");
            Bash.Command(cmd, redirect: true);
        }
        
        CheckCommandOutput(errorCode: 23);
    }
    
    static void DeleteTempFiles()
    {
        Console.Write("Deleting temporary files...");
        Bash.Rm($"/tmp/{DllName}.temp", "-rf");
        CheckCommandOutput(24);
    }

    static void SayHello()
    {
        var title = $" {ToolName} v{ToolVersion} ";
        var newWidth = Width - title.Length;
        var leftBar = new String('-', newWidth / 2);
        string rightBar;

        if (newWidth % 2 > 0)
            rightBar = new String('-', newWidth / 2 + 1);
        else
            rightBar = new String('-', newWidth / 2);
        
        Printer.WriteLine($"\n{leftBar}{Clr.Cyan}{Frmt.Bold}{title}{Reset.Code}{rightBar}");
    }

    static void HelpMenu()
    {
        Printer.WriteLine(
            $"\n            {Frmt.Bold}{Clr.Cyan}Usage:{Reset.Code}\n"
            + $"    {Frmt.Bold}netpkg-tool{Frmt.UnBold} "
            + $"[{Frmt.Underline}Project{Reset.Code}] "
            + $"[{Frmt.Underline}Destination{Reset.Code}] "
            + $"[{Frmt.Underline}Flags{Reset.Code}]\n\n"
            + $"            {Frmt.Bold}{Clr.Cyan}Flags:{Reset.Code}\n"
            + @"     --verbose or -v: Verbose output\n"
            + @"     --compile or -c: Skip restoring dependencies\n"
            + @"        --name or -n: Set ouput file to a custom name\n"
            + @"         --scd or -s: Self-Contained Deployment (SCD)\n"
            + @"        --keep or -k: Keep /tmp/{AppName}.temp directory\n"
            + @"        --help or -h: Help menu (this page)\n\n"
            + @"    More information & source code available on github:\n"
            + @"    https://github.com/phil-harmoniq/netpkg-tool\n"
            + @"    Copyright (c) 2017 - MIT License\n"
        );
        SayBye();
        Environment.Exit(0);
    }

    static void ClearLogs()
    {
        Console.Write($"Clear log at {GetRelativePath(configDir)}/error.log");
        Bash.Rm($"{configDir}/error.log", "-f");
        CheckCommandOutput(errorCode: 5);
        SayBye();
        Environment.Exit(0);
    }

    static void ExitWithError(string message, int code)
    {
        if (Verbose)
        {
            WriteToErrorLog("[Error message was written to verbose output]", code);
        }
        else
        {
            Printer.WriteLine($"{Clr.Red}{message}{Clr.Default}");
            WriteToErrorLog(message, code);
        }
        SayBye();
        Environment.Exit(code);
    }

    static void WriteToErrorLog(string message, int code)
    {
        if (!Directory.Exists(configDir))
            Directory.CreateDirectory(configDir);
        
        using (var tw = new StreamWriter($"{configDir}/error.log", true))
        {
            var now = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
            var dir = Directory.GetCurrentDirectory();

            tw.WriteLine($"{new string('-', Width)}");
            tw.WriteLine($"{GetRelativePath(dir)}$ netpkg-tool {string.Join(' ', Args)}");
            tw.WriteLine($"Errored with code {code} - ({now}):\n");
            tw.WriteLine(message.TrimEnd('\n'));
            tw.WriteLine($"{new string('-', Width)}");
        }
    }

    /// <param name="errorCode">Desired error code if the command didn't run properly</param>
    static void CheckCommandOutput(int errorCode = 1)
    {
        if (Bash.ExitCode != 0)
        {
            SayFail();
            if (string.IsNullOrEmpty(Bash.ErrorMsg))
                ExitWithError(Bash.Output, errorCode);
            else
                ExitWithError(Bash.ErrorMsg, errorCode);
        }
        SayPass();
    }
    
    static string GetRelativePath(string path) =>
        Bash.Command($"cd {path} && dirs -0", redirect: true).Output;

    static string GetAbsolutePath(string path) =>
        Bash.Command($"readlink -f {path}", redirect: true).Output;
    
    static void SayBye() =>
        Console.WriteLine(new String('-', Width) + "\n");

    static void SayTask(string project, string Destination) =>
        Printer.WriteLine($"{Clr.Cyan}{project} => {Destination}{Clr.Default}");

    static void SayFinished(string message) =>
        Printer.WriteLine($"{Clr.Green}{message}{Clr.Default}");

    static void SayPass() =>
        Printer.WriteLine($" {Frmt.Bold}[ {Clr.Green}PASS{Clr.Default} ]{Reset.Code}");

    static void SayFail() =>
        Printer.WriteLine($" {Frmt.Bold}[ {Clr.Red}FAIL{Clr.Default} ]{Reset.Code}");
}
