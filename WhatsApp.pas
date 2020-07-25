unit WhatsApp;

// BIBLIOTECA DE FUNÇÕES DESEVOLVIDA POR VALTER PATRICK SILVA FERREIRA EM 11/05/2020 - valterpatrick@hotmail.com
// Refatorada e adicionada opção de envio direto para App e Web em 24/07/2020 por Belizário G. Ribeiro Filho - belizariogr@gmail.com
// Versão 2.0

interface

uses
  System.StrUtils, System.SysUtils, System.NetEncoding, Winapi.Windows, Winapi.ShellApi, Winapi.TlHelp32, Winapi.PsAPI;

const
  WT_WEB_LINK = 'https://web.whatsapp.com/send?';
  WT_APP_LINK = 'whatsapp://send/?';
  WT_PHONE_PARAM = 'phone';
  WT_TEXT_MSG_PARAM = 'text';

type
  TWhatsApp = class
  private
    class function GetWhatsAppPath: String;
    class function GetNumbers(const Str: String): String;
    class function GetLink(const Phone, Text: String; IsApp: Boolean): String;
  public
    class procedure SendText(const PhoneNumber, Text: String; CountryCode: Integer = 55; OpenToApp: Boolean = True);
  end;

implementation

{ TWhatsApp }

class function TWhatsApp.GetLink(const Phone, Text: String; IsApp: Boolean): String;
begin
  if IsApp then
    Result := WT_APP_LINK + WT_TEXT_MSG_PARAM + '=' + Text + '&' + WT_PHONE_PARAM + '=' + Phone
  else
    Result := WT_WEB_LINK + WT_TEXT_MSG_PARAM + '=' + Text + IfThen(Phone = '', '', '&' + WT_PHONE_PARAM + '=' + Phone);
end;

class function TWhatsApp.GetNumbers(const Str: String): String;
var
  I: Integer;
begin
  Result := '';
  if Length(Trim(Str)) = 0 then
    Exit;
  for I := 0 to Length(Str) do
    if CharInSet(Str[I], ['0' .. '9']) then
      Result := Result + Str[I];
end;

class function TWhatsApp.GetWhatsAppPath: String;

  function GetProcessPID(const ProcessName: String): Cardinal;
  var
    SnapShot: THandle;
    pe: TProcessEntry32;
  begin
    Result := 0;
    SnapShot := CreateToolhelp32Snapshot((TH32CS_SNAPPROCESS or TH32CS_SNAPTHREAD), 0);
    try
      pe.dwSize := SizeOf(TProcessEntry32);
      Process32First(SnapShot, pe);
      repeat
        if (LowerCase(ExtractFileName(pe.szExeFile)) = LowerCase(ProcessName)) then
        begin
          Result := pe.th32ProcessID;
          Exit;
        end;
      until Process32Next(SnapShot, pe) = false;
    finally
      CloseHandle(SnapShot);
    end;
  end;

  function GetPathFromPID(const PID: Cardinal): String;
  var
    hProcess: THandle;
    Path: array [0 .. MAX_PATH - 1] of char;
  begin
    Result := '';
    if PID = 0 then
      Exit;
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PID);
    if hProcess <> 0 then
      try
        if GetModuleFileNameEx(hProcess, 0, Path, MAX_PATH) = 0 then
          Exit;
        Result := Path;
      finally
        CloseHandle(hProcess)
      end;
  end;

begin
  Result := GetPathFromPID(GetProcessPID('whatsapp.exe'));
end;

class procedure TWhatsApp.SendText(const PhoneNumber, Text: String; CountryCode: Integer = 55; OpenToApp: Boolean = True);
var
  vTreatedPhoneNumber, vTreatedMessage, vPath: String;
begin
  if Length(Trim(Text)) = 0 then
    raise Exception.Create('There is no text message to send.');
  vTreatedPhoneNumber := '+' + IfThen(GetNumbers(PhoneNumber) = '', '', IntToStr(CountryCode)) + GetNumbers(PhoneNumber);
  vTreatedMessage := TNetEncoding.URL.Encode(Text);

  vPath := GetWhatsAppPath;
  if OpenToApp and FileExists(vPath) then
    ShellExecute(0, 'open', PChar(vPath), PChar(TWhatsApp.GetLink(vTreatedPhoneNumber, vTreatedMessage, True)), '', 1)
  else
    ShellExecute(0, 'open', PChar(TWhatsApp.GetLink(vTreatedPhoneNumber, vTreatedMessage, false)), '', '', 1);
end;

end.
