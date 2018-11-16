unit petzacommsunit;

interface

uses windows, sysutils, classes, contnrs, wsocketmessaging, wsocket,
  streamablebaseunit, dialogs, forms;

const petzaport = '10263';
  paprotocolver = 1;

type
  TPAmessage = (pamsg_ping, pamsg_connect, pamsg_connect_error, pamsg_chat, pamsg_pushscript);


  TPetzAClient = class(twsocketmessagingclient);
  TPetzCommmessage = class;

  TPetzCommServer = class
  private
    fonserveronline: tnotifyevent;
    procedure changestate(Sender: TObject; OldState, NewState: TSocketState);
    procedure processconnect(client: tpetzaclient; msg: tmemorystream);
    procedure clientconnect(Sender: TObject; Client: TWSocketMessagingClient; Error: Word);
    procedure messageavailable(sender: tobject; msg: tmemorystream);
  public
    socket: TWSocketSMessaging;
    function active: boolean;
    procedure broadcast(msg: tmemorystream); overload;
    procedure broadcast(msg: TPetzCommMessage); overload;
    procedure start;
    procedure stop;
    property onserveronline: tnotifyevent read fonserveronline write fonserveronline;
    constructor create;
    destructor destroy; override;
  end;

  TPetzCommClient = class
  private
    procedure sessionconnected(sender: tobject; error: word);
    procedure messageavailable(sender: tobject; msg: tmemorystream);
    procedure processconnect(packet: TPetzCommmessage);
  public
    socket: TWSocketMessaging;
    function connected: boolean;
    procedure connect(addr: string);
    constructor create;
    destructor destroy; override;
  end;

  TPetzCommMessage = class
  public
    pamsg: Tpamessage;
    buf: tmemorystream;
    procedure sendandfree(client: twsocketmessaging);
    procedure send(client: TWSocketMessaging); virtual;
    procedure decode; virtual;
    constructor create; virtual;
    destructor destroy; override;
  end;
  TPetzcommclass = class of tpetzcommmessage;

  TPetzCommString = class(Tpetzcommmessage)
  private
    ftext: string;
  public
    procedure decode; override;
    constructor create(text: string); reintroduce; virtual;
    procedure send(client: twsocketmessaging); override;
  end;

  TPetzCommConnectError = class(Tpetzcommstring)
  public
    constructor create(text: string); override;
  end;

  TPetzCommServerConnect = class(tpetzcommstring)
  public
    constructor create(text: string); override;
  end;

  TPetzCommPushScript = class(tpetzcommmessage)
  public
    petid: word;
    frames: array of longword;
    loopcount: integer;
    procedure send(client: TWSocketMessaging); override;
    procedure decode; override;
    constructor create; override;
  end;

implementation
uses petzaunit, petzclassesunit, dllpatchunit, bndpetz;

procedure safeshowmessage(const s: string);
begin
 //MessageDlg(s,mtInformation,mbOKCancel,0);
 //application.messagebox(pchar(s),'Message',MB_OK or MB_ICONINFORMATION);
  OutputDebugString(pchar(s));
end;

procedure tpetzcommpushscript.send(client: TWSocketMessaging);
var t1:integer;
begin
  buf.Clear;
  buf.write(petid, 2);
  tnickstream(buf).writeinteger(length(frames));
  for t1:=0 to high(frames) do
   tnickstream(buf).writelongword(frames[t1]);
  buf.write(loopcount, 4);
  inherited;
end;

procedure tpetzcommpushscript.decode;
var t1:integer;
begin
  buf.read(petid, 2);
  setlength(frames,tnickstream(buf).readinteger);
  for t1:=0 to high(frames) do
   frames[t1]:=tnickstream(buf).readinteger;
  buf.read(loopcount, 4);
end;

constructor tpetzcommpushscript.create;
begin
  inherited;
  pamsg := pamsg_pushscript;
end;



constructor tpetzcommconnecterror.create;
begin
  inherited;
  pamsg := pamsg_connect_error;
end;

constructor tpetzcommserverconnect.create(text: string);
begin
  inherited;
  pamsg := pamsg_connect;
end;

constructor tpetzcommstring.create(text: string);
begin
  inherited create;
  ftext := text;
end;

procedure tpetzcommstring.decode;
begin
  ftext := TNickStream(buf).readwordstring;
end;

procedure tpetzCommString.send(client: twsocketmessaging);
begin
  buf.Clear;
  tnickstream(buf).writewordstring(ftext);
  inherited;
end;

procedure tpetzcommmessage.decode;
begin
//
end;

procedure tpetzcommmessage.sendandfree(client: twsocketmessaging);
begin
  try
    send(client);
  finally
    free;
  end;
end;

procedure tpetzcommmessage.send(client: TWSocketMessaging);
var sendstream: tmemorystream;
begin
  sendstream := tmemorystream.create;
  try
    sendstream.write(pamsg, 2);
    sendstream.copyfrom(buf, 0);
    client.sendstream(sendstream);
  finally
    sendstream.free;
  end;
end;

constructor tpetzcommmessage.create;
begin
  buf := TMemoryStream.create;
end;

destructor tpetzcommmessage.destroy;
begin
  buf.free;
end;

procedure tpetzcommserver.changestate(Sender: TObject; OldState, NewState: TSocketState);
begin
  if newstate = wslistening then
    if assigned(fonserveronline) then
      fonserveronline(self);
end;

function tpetzcommserver.active: boolean;
begin
  result := (socket.State = wsListening);
end;

procedure tpetzcommserver.broadcast(msg: TPetzCommMessage);
var t1: integer;
begin
  for t1 := 0 to socket.clientcount - 1 do
    msg.send(socket.client[t1]);
end;

procedure tpetzcommserver.broadcast(msg: tmemorystream);
var t1: integer;
begin
  for t1 := 0 to socket.clientcount - 1 do
    socket.Client[t1].sendstream(msg);
end;

procedure tpetzcommserver.processconnect(client: TPetzAClient; msg: tmemorystream);
var protocol: longword;
begin
  protocol := tnickstream(msg).readlongword;
  if protocol <> paprotocolver then
    TPetzCommConnectError.create('Incorrect protocol version!').sendandfree(client) else
    tpetzcommserverconnect.create('Welcome to PetzA server v1.0').sendandfree(client);
end;

procedure tpetzcommserver.messageavailable(sender: tobject; msg: tmemorystream);
var id: tpamessage;
  client: tpetzaclient;
begin
  client := tpetzaclient(sender);
  msg.read(id, 2);
  case id of
    pamsg_connect: processconnect(client, msg);
  end;
end;

procedure tpetzcommserver.clientconnect(Sender: TObject; Client: TWSocketMessagingClient; Error: Word);
begin
  client.OnMessageAvailable := messageavailable;
end;

procedure tpetzcommserver.start;
begin
  socket.Port := petzaport;
  socket.Proto := 'tcp';
  socket.Addr := '0.0.0.0';
  socket.Listen;
end;

procedure tpetzcommserver.stop;
begin
  socket.Close;
end;

constructor tpetzcommserver.create;
begin
  socket := TWSocketsMessaging.Create(nil);
  socket.ClientClass := TPetzAClient;

  socket.OnClientConnect := clientconnect;
  socket.OnChangeState := changestate;
end;

destructor tpetzcommserver.destroy;
begin
  stop;
  socket.free;
end;

function tpetzcommclient.connected: boolean;
begin
  result := socket.State = wsConnected;
end;

procedure tpetzcommclient.sessionconnected(sender: tobject; error: word);
var stream: tmemorystream;
begin
{Send hello, version and name to server}
  stream := tmemorystream.create;
  try
    tnickstream(stream).writeword(word(pamsg_connect));
    tnickstream(stream).writelongword(paprotocolver);
    tnickstream(stream).writebytestring('Nick');
    TWSocketMessaging(sender).sendstream(stream);
  finally
    stream.free;
  end;
end;

procedure tpetzcommclient.processconnect(packet: TPetzCommmessage);
begin
 //outputdebugstring('Connected successfully');
  safeshowmessage('Connected successfully. ' + TPetzCommString(packet).ftext);
end;

function petzcommclass(id: tpamessage): tpetzcommclass;
begin
  case id of
    pamsg_connect: result := TPetzCommServerConnect;
    pamsg_connect_error: result := TPetzCommConnectError;
    pamsg_pushscript: result := TPetzCommPushScript;
  else begin
      safeshowmessage('Couldn''t find comm class');
      result := TPetzCommmessage;
    end;
  end;
end;

procedure tpetzcommclient.messageavailable(sender: tobject; msg: tmemorystream);
var id: tpamessage;
  packet: TPetzCommmessage;
  pet: TPetzPetSprite;
  inst: TPetzClassInstance;
begin
  petza.processingmessage := true;
  try

    msg.Read(id, 2);
    packet := petzcommclass(id).create;
    try
      if msg.size > 2 then
        packet.buf.CopyFrom(msg, msg.size - 2);
      packet.buf.seek(0, sofrombeginning);
      packet.decode;

      case id of
        pamsg_connect: processconnect(packet);
        pamsg_connect_error: messagebox(0, 'There was a problem trying to connect', 'Error', mb_ok or MB_ICONEXCLAMATION);
        pamsg_pushscript: begin
            inst := petzclassesman.findclassinstance(cnPetsprite);
            if inst <> nil then begin
              pet := TPetzPetSprite(inst.instance);
              thiscall(pet, rimports.scriptsprite_pushscript, [cardinal(@TPetzCommPushScript(packet).frames[0]), cardinal(TPetzCommPushScript(packet).loopcount), cardinal(pet.scriptstack)]);
            end;
          end;
      else outputdebugstring('Couldn''t find message id');
      end;
    finally
      packet.free;
    end;
  finally
    petza.processingmessage := false;
  end;
end;

procedure tpetzcommclient.connect(addr: string);
begin
  socket.Addr := addr;
  socket.port := petzaport;
  socket.Proto := 'tcp';
  socket.Connect;
end;

constructor tpetzcommclient.create;
begin
  socket := TWSocketMessaging.create(nil);
  socket.OnSessionConnected := sessionconnected;
  socket.OnMessageAvailable := messageavailable;
end;

destructor tpetzcommclient.destroy;
begin
  socket.free;
end;


end.

