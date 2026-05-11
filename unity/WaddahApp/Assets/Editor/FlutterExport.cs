using System.IO;
using UnityEditor;
using UnityEngine;

public class FlutterExport
{
    [MenuItem("Flutter/Export Android %e")]
    public static void ExportAndroid()
    {
        EditorUserBuildSettings.SwitchActiveBuildTarget(
            BuildTargetGroup.Android, BuildTarget.Android);

        EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
        EditorUserBuildSettings.exportAsGoogleAndroidProject = true;

        var options = BuildOptions.AcceptExternalModificationsToPlayer;
        var report = BuildPipeline.BuildPlayer(
            GetScenes(),
            GetExportPath(),
            BuildTarget.Android,
            options
        );

        if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            Debug.Log("Export succeeded: " + GetExportPath());
        else
            Debug.LogError("Export failed");
    }

    static string[] GetScenes()
    {
        return new string[] { "Assets/Scenes/ARGame.unity" };
    }

    static string GetExportPath()
    {
        // Export NEXT TO the Flutter project, not inside it
        string exportPath = @"C:\Users\jori-\unityExport";
        Debug.Log("Exporting to: " + exportPath);
        Directory.CreateDirectory(exportPath);
        return exportPath;
    }
}