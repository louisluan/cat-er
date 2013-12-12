Sub TabToCsv()

    Const ForReading = 1, ForWriting = 2
    Dim fso, MyTabFile, MyCsvFile, FileName
    Dim strFileContent As String
    Set fso = CreateObject("Scripting.FileSystemObject")

    ' Open the file for input.
    Set MyTabFile = fso.OpenTextFile("C:\programs\data\GTARET\TRD_Weekm.csv", ForReading)

    ' Read the entire file and close.
    strFileContent = MyTabFile.ReadAll
    MyTabFile.Close

    ' Replace tabs with commas.
    strFileContent = Replace(expression:=strFileContent, _
                             Find:=vbTab, Replace:=",")
    ' Can use Chr(9) instead of vbTab.

    ' Open a new file for output, write everything, and close.
    Set MyCsvFile = fso.OpenTextFile("C:\programs\data\GTARET\TRD_Weekm1.csv", ForWriting, True)
    MyCsvFile.Write strFileContent
    MyCsvFile.Close

End Sub