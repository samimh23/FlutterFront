import 'package:socket_io_client/socket_io_client.dart' as IO;

class AuctionSocketClient {
  static final AuctionSocketClient _instance = AuctionSocketClient._internal();
  factory AuctionSocketClient() => _instance;
  AuctionSocketClient._internal();

  late IO.Socket socket;
  bool _isConnected = false;

  void connect() {
    if (_isConnected) return;
    socket = IO.io('http://localhost:3008', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected');
      _isConnected = true;
    });
    socket.onDisconnect((_) {
      print('Disconnected');
      _isConnected = false;
    });

    socket.on('auctionUpdated', (data) {
      print('Auction updated');
    });

    socket.on('joinedAuction', (data) {
      print('Joined auction');
    });

    socket.on('bidSuccess', (data) {
      print('Bid success');
    });

    socket.on('bidError', (data) {
      print('Bid error');
    });
  }

  void joinAuction(String auctionId) {
    connect(); // Ensure connection before joining
    socket.emit('joinAuction', {'auctionId': auctionId});
  }

  void placeBid(String auctionId, String bidderId, num bidAmount) {
    connect(); // Ensure connection before placing bid
    socket.emit('bidPlaced', {
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidAmount': bidAmount,
    });
  }
}