unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Dos, process;

type

  { TYARAllamaWindow }

  TYARAllamaWindow = class(TForm)
    btnBrowse: TButton;
    btnRunLlama: TButton;
    btnSelectTarget: TButton;
    edtTargetFile: TEdit;
    edtDirectory: TEdit;
    lblSelectFile: TLabel;
    lblSelectScripts: TLabel;
    dlgSelectFile: TOpenDialog;
    dlgSelectDirectory: TSelectDirectoryDialog;
    Process1: TProcess;
    resultsWindow: TMemo;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnSelectTargetClick(Sender: TObject);
    procedure btnRunLlamaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  YARAllamaWindow: TYARAllamaWindow;

implementation

{$R *.lfm}

{ TYARAllamaWindow }

procedure TYARAllamaWindow.FormCreate(Sender: TObject);
begin
  edtDirectory.Text := ExtractFileDir(ParamStr(0));
  resultsWindow.Lines.Clear;
  edtTargetFile.Text := '';
  edtDirectory.Text := '';
end;

procedure TYARAllamaWindow.btnBrowseClick(Sender: TObject);
begin
  if not (dlgSelectDirectory.Execute) then
    Exit;
  edtDirectory.Text := dlgSelectDirectory.FileName;
end;

procedure TYARAllamaWindow.btnSelectTargetClick(Sender: TObject);
begin
  if not (dlgSelectFile.Execute) then
    Exit;
  edtTargetFile.Text := dlgSelectFile.FileName;
end;

procedure TYARAllamaWindow.btnRunLlamaClick(Sender: TObject);
var
  ListOfFiles: array of string;
  SearchResult: SearchRec;
  i: integer;
  outputString: string;
  scriptName, targetName, myCommand: string;

begin
  SearchResult := Default(SearchRec);
  SetLength(ListOfFiles, 0);
  targetName := edtTargetFile.Text;

  { Check that scripts and files are selected }

  if (edtDirectory.Text <> '') and (edtTargetFile.Text <> '') then
  begin

    { Gets list of scripts }
    FindFirst(edtDirectory.Text + DirectorySeparator + '*.yar', ReadOnly, SearchResult);
    while (DosError = 0) do
    begin
      SetLength(ListOfFiles, Length(ListOfFiles) + 1); // Increase the list
      ListOfFiles[High(ListOfFiles)] := SearchResult.Name;
      // Add it at the end of the list
      FindNext(SearchResult);
    end;
    FindClose(SearchResult);

    { Loop through the scripts }
    for i := Low(ListOfFiles) to High(ListOfFiles) do
    begin
      scriptName := edtDirectory.Text + DirectorySeparator + ListOfFiles[i];
      RunCommand('/bin/yara', [scriptName, targetName], outputString);
      if (outputString = '') then
        resultsWindow.Lines.Add(ListOfFiles[i] + ' - No results found')
      else
      begin
        resultsWindow.Lines.Add(LineEnding + ListOfFiles[i]);
        resultsWindow.Lines.Add(outputString);
      end;
    end;
  end
  else
    ShowMessage('Ensure that a Scripts Folder and a Target File have been selected');

end;

end.
