{ The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  The Original Code is DIMimeStreams.pas.

  The Initial Developer of the Original Code is Ralf Junker <delphi@yunqa.de>.

  All Rights Reserved.

------------------------------------------------------------------------------ }

unit DIMimeStreams;

{$I DICompilers.inc}

interface

uses
  {$IFDEF HAS_UNITSCOPE}System.Classes{$ELSE}Classes{$ENDIF};

procedure MimeEncodeStream(
  const InputStream: TStream;
  const OutputStream: TStream);

procedure MimeEncodeStreamNoCRLF(
  const InputStream: TStream;
  const OutputStream: TStream);

procedure MimeDecodeStream(
  const InputStream: TStream;
  const OutputStream: TStream);

procedure MimeEncodeFile(
  const InputFileName: string;
  const OutputFileName: string);

procedure MimeEncodeFileNoCRLF(
  const InputFileName: string;
  const OutputFileName: string);

procedure MimeDecodeFile(
  const InputFileName: string;
  const OutputFileName: string);

implementation

uses
  DISystemCompat,
  {$IFDEF HAS_UNITSCOPE}System.SysUtils{$ELSE}SysUtils{$ENDIF}, DIMime;

const

  MIME_BUFFER_SIZE = MIME_DECODED_LINE_BREAK * 3 * 4 * 4;

procedure MimeEncodeStream(
  const InputStream: TStream;
  const OutputStream: TStream);
var
  InputBuffer: packed array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: packed array[0..(MIME_BUFFER_SIZE + 2) div 3 * 4 + MIME_BUFFER_SIZE div MIME_DECODED_LINE_BREAK * 2 - 1] of Byte;
  BytesRead: NativeUInt;
  iDelta, ODelta: NativeUInt;
begin
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));

  while BytesRead = SizeOf(InputBuffer) do
    begin
      MimeEncodeFullLines(InputBuffer, SizeOf(InputBuffer), OutputBuffer);
      OutputStream.Write(OutputBuffer, SizeOf(OutputBuffer));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;

  MimeEncodeFullLines(InputBuffer, BytesRead, OutputBuffer);

  iDelta := BytesRead div MIME_DECODED_LINE_BREAK;
  ODelta := iDelta * (MIME_ENCODED_LINE_BREAK + 2);
  iDelta := iDelta * MIME_DECODED_LINE_BREAK;
  MimeEncodeNoCRLF((PAnsiChar(@InputBuffer) + iDelta)^, BytesRead - iDelta, (PAnsiChar(@OutputBuffer) + ODelta)^);

  OutputStream.Write(OutputBuffer, MimeEncodedSize(BytesRead));
end;

procedure MimeEncodeStreamNoCRLF(
  const InputStream: TStream;
  const OutputStream: TStream);
var
  InputBuffer: packed array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: packed array[0..((MIME_BUFFER_SIZE + 2) div 3) * 4 - 1] of Byte;
  BytesRead: NativeUInt;
begin
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
  while BytesRead = SizeOf(InputBuffer) do
    begin
      MimeEncodeNoCRLF(InputBuffer, SizeOf(InputBuffer), OutputBuffer);
      OutputStream.Write(OutputBuffer, SizeOf(OutputBuffer));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;

  MimeEncodeNoCRLF(InputBuffer, BytesRead, OutputBuffer);
  OutputStream.Write(OutputBuffer, MimeEncodedSizeNoCRLF(BytesRead));
end;

procedure MimeDecodeStream(
  const InputStream: TStream;
  const OutputStream: TStream);
var
  ByteBuffer, ByteBufferSpace: NativeUInt;
  InputBuffer: packed array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: packed array[0..(MIME_BUFFER_SIZE + 3) div 4 * 3 - 1] of Byte;
  BytesRead: NativeUInt;
begin
  ByteBuffer := 0;
  ByteBufferSpace := 4;
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
  while BytesRead > 0 do
    begin
      OutputStream.Write(OutputBuffer, MimeDecodePartial(InputBuffer, BytesRead, OutputBuffer, ByteBuffer, ByteBufferSpace));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;
  OutputStream.Write(OutputBuffer, MimeDecodePartialEnd(OutputBuffer, ByteBuffer, ByteBufferSpace));
end;

procedure MimeEncodeFile(
  const InputFileName: string;
  const OutputFileName: string);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeEncodeStream(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

procedure MimeEncodeFileNoCRLF(
  const InputFileName: string;
  const OutputFileName: string);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeEncodeStreamNoCRLF(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

procedure MimeDecodeFile(
  const InputFileName: string;
  const OutputFileName: string);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeDecodeStream(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

end.

