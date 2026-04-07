using Godot;
using Godot.Collections;

using GdUnit4;

// GdUnit4 GDScript - C# API wrapper
public partial class GdUnit4CSharpApi : RefCounted
{
	public static string Version() => GdUnit4MonoAPI.Version();
	
	public static bool IsTestSuite(string classPath) => GdUnit4MonoAPI.IsTestSuite(classPath);
	
	public static RefCounted Executor(Node listener) => (RefCounted)GdUnit4MonoAPI.Executor(listener);
	
	public static GdUnit4.CsNode? ParseTestSuite(string classPath) => GdUnit4MonoAPI.ParseTestSuite(classPath);
	
	public static Dictionary CreateTestSuite(string sourcePath, int lineNumber, string testSuitePath) =>
		GdUnit4MonoAPI.CreateTestSuite(sourcePath, lineNumber, testSuitePath);
}
