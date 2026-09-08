import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_go/models/card/aime.dart';
import 'package:hinata_go/models/card/banapass.dart';
import 'package:hinata_go/models/card/tunion.dart';
import 'package:hinata_go/models/remote_instance.dart';
import 'package:hinata_go/services/api_service.dart';
import 'package:hinata_go/services/remote_crypto.dart';
import 'package:http/http.dart' as http;

class RecordingClient extends http.BaseClient {
  RecordingClient({
    this.capabilities = const {
      'agents': [
        {'cardProtocol': 2, 'clientVersion': '1.1.3'},
      ],
    },
  });

  final Map<String, dynamic> capabilities;
  http.BaseRequest? request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    final body = request.method == 'GET' ? jsonEncode(capabilities) : '{}';
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      request: request,
    );
  }
}

void main() {
  final card = Aime(
    Uint8List.fromList([1, 2, 3, 4]),
    0x08,
    0x0004,
    Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
  );

  test('sends a V2 card body when password is empty', () async {
    final client = RecordingClient();
    final instance = RemoteInstance(
      id: 'id',
      name: 'name',
      icon: 'bear',
      url: 'https://example.test/remote',
    );

    final result = await ApiService(
      httpClient: client,
    ).sendCardData(instance: instance, card: card);

    expect(result.success, isTrue);
    expect(jsonDecode((client.request! as http.Request).body), {
      'action': 'SET_CARD_V2',
      'body': {
        'card': {
          'type': 'aime',
          'id': '01020304',
          'sak': 8,
          'atqa': 4,
          'accessCode': '00010203040506070809',
        },
      },
    });
  });

  test(
    'keeps SET_CARD_V2 and sends legacy Banapass fields to an old DLL',
    () async {
      final client = RecordingClient(
        capabilities: const {
          'agents': [
            {'cardProtocol': 2, 'clientVersion': '1.1.2'},
          ],
        },
      );
      final instance = RemoteInstance(
        id: 'id',
        name: 'name',
        icon: 'bear',
        url: 'https://example.test/remote',
      );
      final banapass = Banapass.fromBlocks(
        Uint8List.fromList([
          0,
          2,
          0x4e,
          0x42,
          0x47,
          0x49,
          0x43,
          0x36,
          0x65,
          0xd8,
          0x20,
          0x63,
          0x36,
          0xcd,
          0xb5,
          0xc2,
        ]),
        0x08,
        0x0400,
        block1: Uint8List.fromList([
          0x00,
          0x02,
          0x4e,
          0x42,
          0x47,
          0x49,
          0x43,
          0x36,
          0x65,
          0xd8,
          0x20,
          0x63,
          0x36,
          0xcd,
          0xb5,
          0xc2,
        ]),
        block2: Uint8List.fromList([
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x30,
          0x74,
          0x60,
          0x56,
          0x64,
          0x44,
          0x48,
          0x17,
          0x14,
          0x90,
        ]),
        accessCode: '30746056644448171490',
        serial: 205050,
        keyNumber: 6,
        unknown04: 0,
        unknown06: 3,
        appData: 0,
        dualKey: true,
      );

      final result = await ApiService(
        httpClient: client,
      ).sendCardData(instance: instance, card: banapass);

      expect(result.success, isTrue);
      final request =
          jsonDecode((client.request! as http.Request).body)
              as Map<String, dynamic>;
      expect(request['action'], 'SET_CARD_V2');
      final payload = request['body']['card'] as Map<String, dynamic>;
      expect(payload['type'], 'banapass');
      expect(payload['block1'], '00024e424749433665d8206336cdb5c2');
      expect(payload['block2'], '00000000000030746056644448171490');
      expect(payload['accessCode'], '30746056644448171490');
      expect(payload.containsKey('serial'), isFalse);
      expect(payload.containsKey('keyNumber'), isFalse);
    },
  );

  test('sends canonical Banapass fields to a new DLL', () async {
    final client = RecordingClient(
      capabilities: const {
        'agents': [
          {'cardProtocol': 2, 'clientVersion': '1.1.3'},
        ],
      },
    );
    final instance = RemoteInstance(
      id: 'id',
      name: 'name',
      icon: 'bear',
      url: 'https://example.test/remote',
    );
    final banapass = Banapass.fromCanonical(
      Uint8List.fromList([1, 2, 3, 4]),
      0x08,
      0x0400,
      serial: 205050,
      keyNumber: 6,
      unknown04: 0,
      unknown06: 3,
      appData: 0,
      dualKey: false,
    );

    final result = await ApiService(
      httpClient: client,
    ).sendCardData(instance: instance, card: banapass);

    expect(result.success, isTrue);
    final request =
        jsonDecode((client.request! as http.Request).body)
            as Map<String, dynamic>;
    expect(request['action'], 'SET_CARD_V2');
    final payload = request['body']['card'] as Map<String, dynamic>;
    expect(payload['serial'], 205050);
    expect(payload['keyNumber'], 6);
    expect(payload['unknown04'], 0);
    expect(payload['unknown06'], 3);
    expect(payload['appData'], 0);
    expect(payload['dualKey'], false);
  });

  test('sends a T-Union model without a legacy game payload', () async {
    final client = RecordingClient();
    final instance = RemoteInstance(
      id: 'id',
      name: 'name',
      icon: 'bear',
      url: 'https://example.test/remote',
    );
    final tunion = TUnion(
      Uint8List.fromList([1, 2, 3, 4]),
      0x20,
      0x0400,
      cardNumber: '01234567890123456789',
      balance: 0,
      transactions: const [],
    );

    final result = await ApiService(
      httpClient: client,
    ).sendCardData(instance: instance, card: tunion);

    expect(result.success, isTrue);
    final request = jsonDecode((client.request! as http.Request).body);
    expect(request['action'], 'SET_CARD_V2');
    expect(request['body']['card']['type'], 'tunion');
    expect(request['body']['card']['cardNumber'], '01234567890123456789');
  });

  test(
    'sends an encrypted SET_CARD body when password is configured',
    () async {
      final client = RecordingClient();
      final instance = RemoteInstance(
        id: 'id',
        name: 'name',
        icon: 'bear',
        url: 'https://example.test/remote',
        password: 'test-remote-password',
        encryptionSalt: 'ABEiM0RVZneImaq7zN3u_w',
      );

      final result = await ApiService(
        httpClient: client,
      ).sendCardData(instance: instance, card: card);

      final envelope =
          jsonDecode((client.request! as http.Request).body)
              as Map<String, dynamic>;
      final message = await RemoteCrypto.decryptMessage(
        password: instance.password,
        envelope: envelope,
      );

      expect(result.success, isTrue);
      expect(envelope['action'], 'E2EE_V1');
      expect(message['action'], 'SET_CARD_V2');
      expect(message['body'], {
        'card': {
          'type': 'aime',
          'id': '01020304',
          'sak': 8,
          'atqa': 4,
          'accessCode': '00010203040506070809',
        },
      });
    },
  );
}
