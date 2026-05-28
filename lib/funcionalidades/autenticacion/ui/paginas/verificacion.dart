import 'package:flutter/material.dart';

class OtpAutoReadWidget extends StatefulWidget {
  final Function(String) onCodeReceived;
  final Function() reenviarCodigo;

  const OtpAutoReadWidget({
    Key? key,
    required this.onCodeReceived,
    required this.reenviarCodigo,
  }) : super(key: key);

  @override
  State<OtpAutoReadWidget> createState() => _OtpAutoReadWidgetState();
}

class _OtpAutoReadWidgetState extends State<OtpAutoReadWidget> {
  final TextEditingController _controller = TextEditingController();
  String _otpCode = '';
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
          _startTimer();
        });
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          title: Text("Verificación SMS"),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.purple],
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Enviamos un código SMS a tu número',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Campo OTP con ícono
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.sms),
                    suffixIcon: _otpCode.length == 6
                        ? IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green,
                            ),
                            tooltip: "Verificar código",
                            onPressed: () => widget.onCodeReceived(_otpCode),
                          )
                        : const Icon(Icons.sms, color: Colors.grey),
                    hintText: 'Código de 6 dígitos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _otpCode = value);
                    if (value.length == 4) {
                      widget.onCodeReceived(value);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Timer y reenvío
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_canResend)
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            'Reenviar en $_timerSeconds segundos',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    if (_canResend)
                      TextButton.icon(
                        onPressed: () {
                          widget.reenviarCodigo();
                          setState(() {
                            _timerSeconds = 60;
                            _canResend = false;
                            _startTimer();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reenviar código'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_otpCode.length == 4) ...[
                 Center(child:  ElevatedButton(
                    onPressed: () => widget.onCodeReceived(_otpCode),
                    child: Text("Validar Codigo"),
                  ),)
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
