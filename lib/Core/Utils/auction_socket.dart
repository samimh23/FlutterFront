import 'package:socket_io_client/socket_io_client.dart' as IO;

class AuctionSocketClient {
  static final AuctionSocketClient _instance = AuctionSocketClient._internal();
  factory AuctionSocketClient() => _instance;
  AuctionSocketClient._internal();

  late IO.Socket socket;
  bool _isConnected = false;

  // Add callbacks for each event so UI can subscribe
  Function(dynamic)? onConnected;
  Function(dynamic)? onBidderJoined;
  Function(dynamic)? onBidderLeft;
  Function(dynamic)? onBidderJoinedAuction;
  Function(dynamic)? onJoinedUserRoom;
  Function(dynamic)? onJoinedAuction;
  Function(dynamic)? onAuctionUpdated;
  Function(dynamic)? onBidSuccess;
  Function(dynamic)? onBidError;
  Function(dynamic)? onOrderCreated;
  Function(dynamic)? onOrderError;
  Function(dynamic)? onAuctionEnded;
  Function(dynamic)? onSocketError;

  void connect() {
    if (_isConnected) return;
    socket = IO.io('http://localhost:3008', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected to auction platform');
      _isConnected = true;
    });

    socket.onDisconnect((_) {
      print('Disconnected from auction platform');
      _isConnected = false;
    });

    // All backend event listeners
    socket.on('connected', (data) {
      print('SERVER: ${data['message']}');
      if (onConnected != null) onConnected!(data);
    });

    socket.on('bidderJoined', (data) {
      print('SERVER: ${data['message']}');
      if (onBidderJoined != null) onBidderJoined!(data);
    });

    socket.on('bidderLeft', (data) {
      print('SERVER: ${data['message']}');
      if (onBidderLeft != null) onBidderLeft!(data);
    });

    socket.on('bidderJoinedAuction', (data) {
      print('SERVER: ${data['message']}');
      if (onBidderJoinedAuction != null) onBidderJoinedAuction!(data);
    });

    socket.on('joinedUserRoom', (data) {
      print('You joined your user room: ${data['userId']}');
      if (onJoinedUserRoom != null) onJoinedUserRoom!(data);
    });

    socket.on('joinedAuction', (data) {
      print(data['message'] ?? 'Joined auction');
      if (onJoinedAuction != null) onJoinedAuction!(data);
    });

    socket.on('auctionUpdated', (data) {
      print(data['message'] ?? 'Auction updated');
      if (onAuctionUpdated != null) onAuctionUpdated!(data);
    });

    socket.on('bidSuccess', (data) {
      print(data['message'] ?? 'Bid success');
      if (onBidSuccess != null) onBidSuccess!(data);
    });

    socket.on('bidError', (data) {
      print(data['error'] ?? 'Bid error');
      if (onBidError != null) onBidError!(data);
    });

    socket.on('orderCreated', (data) {
      print('Order created for auction: ${data['auctionId']}');
      if (onOrderCreated != null) onOrderCreated!(data);
    });

    socket.on('orderError', (data) {
      print('Order error: ${data['error']}');
      if (onOrderError != null) onOrderError!(data);
    });

    socket.on('auctionEnded', (data) {
      print('Auction ended: ${data['auctionId']}');
      if (onAuctionEnded != null) onAuctionEnded!(data);
    });

    socket.on('error', (data) {
      print('Socket error: $data');
      if (onSocketError != null) onSocketError!(data);
    });
  }

  void registerUser(String userId) {
    connect();
    socket.emit('registerUser', {'userId': userId});
  }

  void joinUserRoom(String userId) {
    connect();
    socket.emit('joinUserRoom', {'userId': userId});
  }

  void joinAuction(String auctionId, String bidderId) {
    connect();
    socket.emit('joinAuction', {'auctionId': auctionId, 'bidderId': bidderId});
  }

  void placeBid(String auctionId, String bidderId, num bidAmount) {
    connect();
    socket.emit('bidPlaced', {
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidAmount': bidAmount,
    });
  }

  void selectMarket(String auctionId, String marketId) {
    connect();
    socket.emit('marketSelected', {
      'auctionId': auctionId,
      'marketId': marketId,
    });
  }
}