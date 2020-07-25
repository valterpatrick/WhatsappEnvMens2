unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Web.HTTPApp, System.NetEncoding, Whatsapp, Vcl.Samples.Spin;

type
  TFrmPrincipal = class(TForm)
    GroupConfig: TGroupBox;
    Label3: TLabel;
    SpinCodigoPais: TSpinEdit;
    Label4: TLabel;
    CmbTipoEnvio: TComboBox;
    GroupEnvio: TGroupBox;
    Label1: TLabel;
    EdtNumero: TEdit;
    Label2: TLabel;
    MemMensagem: TMemo;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private

  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}


procedure TFrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  TWhatsApp.SendText(EdtNumero.Text, MemMensagem.Text, SpinCodigoPais.Value, CmbTipoEnvio.ItemIndex = 0);
end;

end.
