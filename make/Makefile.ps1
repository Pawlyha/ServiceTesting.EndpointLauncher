Define-Step -Name "Update Assembly Info" -Target "DEV,BUILD" -Body {
. (require 'psmake.mod.update-version-info')
	Update-VersionInAssemblyInfo $VERSION
}

Define-Step -Name "Build solution" -Target "DEV,BUILD" -Body {

	call $Context.NuGetExe restore Wonga.ServiceTesting.EndpointLauncher.sln
	call "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" Wonga.ServiceTesting.EndpointLauncher.sln /t:"Clean,Build" /p:Configuration=Release /m /verbosity:m /nologo /p:TreatWarningsAsErrors=true /tv:14.0
}

Define-Step -Name "Test" -Target "DEV,BUILD" -Body {
	. (require 'psmake.mod.testing')
	
    $tests = @()
    $tests += Define-NUnitTests -GroupName 'Tests' -ReportName 'tests' -TestAssembly 'Wonga.ServiceTesting.EndpointLauncher.Tests\bin\Release\Wonga.ServiceTesting.EndpointLauncher.Tests.dll'
    
    $tests | Run-Tests -EraseReportDirectory -ReportDirectory "reports"
}

Define-Step -Name "Tests" -Target "DEV,BUILD" -Body {
	. (require 'psmake.mod.testing')
	
	Define-NUnitTests -GroupName 'Tests' -ReportName 'test-results' -TestAssembly '*\bin\Release\*.Tests.dll' `
		| Run-Tests -EraseReportDirectory -ReportDirectory "reports"
}

Define-Step -Name "Package" -Target "DEV,BUILD" -Body {
	. (require 'psmake.mod.packaging')

	Find-VSProjectsForPackaging | Package-VSProject
}