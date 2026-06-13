import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart' show SystemEvent, SystemEventType;
import 'package:astral/core/app_s/file_logger.dart';

/// 日志捕获管理器 - 单例类
class LogCapture {
  static LogCapture? _instance;
  RawDatagramSocket? _udpSocket;
  bool _isCapturing = false;

  // 工厂构造函数，获取单例实例
  factory LogCapture() {
    _instance ??= LogCapture._internal();
    return _instance!;
  }

  LogCapture._internal();

  /// 开始捕获UDP日志
  Future<void> startCapture({
    String host = '127.0.0.1',
    int port = 9999,
  }) async {
    if (_isCapturing) return;
    debugPrint('准备绑定UDP端口: $host:$port');
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress(host), port);
      debugPrint('UDP端口绑定成功: $host:$port');
      _isCapturing = true;
      _udpSocket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = _udpSocket!.receive();
            if (datagram != null) {
              try {
                final logData = utf8.decode(datagram.data);
                if (logData.isNotEmpty) {
                  // 拦截系统事件 → Toast
                  if (logData.startsWith('__SYS__:')) {
                    _handleSysEvent(logData.substring(8));
                    return;
                  }
                  _addLogToSignal(
                    '[${DateTime.now().toString().substring(11, 19)}] $logData',
                  );
                }
              } catch (e) {
                debugPrint('UDP log decode error: $e');
              }
            }
          }
        },
        onError: (error) {
          debugPrint('UDP socket error: $error');
          _isCapturing = false;
        },
        onDone: () {
          _isCapturing = false;
        },
      );
      debugPrint('UDP log capture started on $host:$port');
    } catch (e) {
      debugPrint('Failed to start UDP log capture: $e');
      _isCapturing = false;
      rethrow; // 关键：抛出异常，避免卡住
    }
  }

  /// 停止捕获日志
  void stopCapture() {
    _udpSocket?.close();
    _udpSocket = null;
    _isCapturing = false;
    debugPrint('UDP log capture stopped');
  }

  /// 房间直接添加日志
  void addRoomLog(String roomName, String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [$roomName] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加系统日志
  void addSystemLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [SYSTEM] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加网络日志
  void addNetworkLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [NETWORK] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加连接日志
  void addConnectionLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [CONNECTION] $message';
    _addLogToSignal(logEntry);
  }

  /// 处理 Rust 侧发来的系统事件
  void _handleSysEvent(String payload) {
    final connState = ServiceManager().connectionState;
    if (payload.startsWith('kicked:')) {
      final by = payload.substring(7);
      _addLogToSignal('[KICK] 玩家被踢出: $by');
      connState.systemEvent.value = SystemEvent(SystemEventType.kicked, message: by);
    } else if (payload.startsWith('room_full')) {
      _addLogToSignal('[FULL] 房间已满，强制断开');
      connState.systemEvent.value = const SystemEvent(SystemEventType.roomFull);
      // 满员强制断开：把这个超限玩家踢回大厅
      connState.systemEvent.value = const SystemEvent(SystemEventType.roomFull);
    } else if (payload.startsWith('peer_left:')) {
      final leftId = payload.substring(10);
      _addLogToSignal('[LEAVE] Peer 离开: $leftId');
      _handlePeerLeft(leftId);
    } else {
      // 其他系统事件记入日志
      _addLogToSignal('[SYS] $payload');
    }
  }

  /// 房主继承：如果离开的是 Host，转移给第一个存活 Peer
  void _handlePeerLeft(String leftId) {
    final ui = ServiceManager().uiState;
    final conn = ServiceManager().connectionState;
    final nodes = conn.netStatus.value?.nodes ?? [];
    final hostIdx = ui.hostIndex.value;

    // 检查离开的是否为当前 Host
    final allPeers = nodes.where((n) {
      final ct = (n.connType as String?) ?? '';
      final ip = (n.ipv4 as String?) ?? '';
      return ct != 'server' && ip != '0.0.0.0';
    }).toList();

    // 如果离开了的 peer index 等于 hostIndex，触发继承
    if (hostIdx >= allPeers.length || allPeers.isEmpty) {
      // Host 是最后一个，重置
      ui.hostIndex.value = 0;
      return;
    }

    // 简单继承：如果 host 不是索引 0，把第一个活着的 peer 设为新 host
    if (hostIdx == 0 || allPeers.length == 1) {
      ui.hostIndex.value = 0;
      if (allPeers.isNotEmpty) {
        final newHost = (allPeers.first.hostname as String?) ?? 'Unknown';
        _addLogToSignal('[HOST] 房主离开，继承者: $newHost');
        conn.systemEvent.value = SystemEvent(
          SystemEventType.kicked,
          message: 'inherit:$newHost',
        );
      }
    }
  }

  /// 添加错误日志
  void addErrorLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [ERROR] $message';
    _addLogToSignal(logEntry);
    FileLogger().error(message); // 同时写入文件
  }

  /// 添加UDP原始日志（不添加时间戳，直接使用原始数据）
  void addRawUdpLog(String message) {
    _addLogToSignal(message);
  }

  /// 清空日志
  void clearLogs() {
    final currentLogs = List<String>.from(
      ServiceManager().appSettingsState.logs.value,
    );
    currentLogs.clear();
    ServiceManager().appSettingsState.logs.value = currentLogs;
  }

  /// 获取最近的日志条目
  List<String> getRecentLogs(int count) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    if (currentLogs.length <= count) {
      return List<String>.from(currentLogs);
    }
    return currentLogs.sublist(currentLogs.length - count);
  }

  /// 根据关键词过滤日志
  List<String> filterLogs(String keyword) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    return currentLogs
        .where((log) => log.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  /// 根据日志类型过滤
  List<String> filterLogsByType(String type) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    return currentLogs.where((log) => log.contains('[$type]')).toList();
  }

  /// 内部方法：添加日志到信号
  void _addLogToSignal(String logEntry) {
    final currentLogs = List<String>.from(
      ServiceManager().appSettingsState.logs.value,
    );
    currentLogs.add(logEntry);
    debugPrint('LOG: $logEntry');

    // 限制日志数量，保留最新的1000条
    if (currentLogs.length > 1000) {
      currentLogs.removeRange(0, currentLogs.length - 1000);
    }

    ServiceManager().appSettingsState.logs.value = currentLogs;
  }

  /// 获取捕获状态
  bool get isCapturing => _isCapturing;

  /// 获取日志总数
  int get logCount => ServiceManager().appSettingsState.logs.value.length;

  /// 导出日志为字符串
  String exportLogsAsString() {
    return ServiceManager().appSettingsState.logs.value.join('\n');
  }

  /// 获取UDP Socket信息
  String? get socketInfo {
    if (_udpSocket != null) {
      return '${_udpSocket!.address.address}:${_udpSocket!.port}';
    }
    return null;
  }
}
