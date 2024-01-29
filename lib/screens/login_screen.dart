import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:taxman_app/screens/upload_vouchers.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isUsingBiometrics = false;

  Future<void> _authenticateWithBiometrics() async {
    bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    if (canAuthenticateWithBiometrics) {
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Toque no sensor para fazer login',
        );
        if (authenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadVouchersPage()),
          );
        }
      } on Exception catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(),
            _buildLoginForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: Duration(milliseconds: 1400),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: 110,
              width: 80,
              height: 150,
              child: FadeInRight(
                duration: Duration(milliseconds: 1500),
                child: Image.asset('assets/images/cloud.png'),
              ),
            ),
            Positioned(
              left: 5,
              top: 80,
              width: 100,
              height: 250,
              child: FadeInLeft(
                duration: Duration(milliseconds: 1600),
                child: Image.asset('assets/images/code.png'),
              ),
            ),
            Positioned(
              right: 3,
              top: 60,
              width: 110,
              height: 230,
              child: FadeInRight(
                duration: Duration(milliseconds: 1700),
                child: Image.asset('assets/images/graph.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          FadeInUp(
            duration: Duration(milliseconds: 1800),
            child: _buildCombinedTextField(),
          ),
          SizedBox(height: 30),
          _buildLoginButton(context),
          FadeInUp(
            duration: Duration(milliseconds: 2000),
            child: _buildBiometricSwitch(),
          ),
          SizedBox(height: 30),
          FadeInUp(
            duration: Duration(milliseconds: 2100),
            child: Text(
              "Esqueceu sua senha?",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedTextField() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color.fromRGBO(117, 117, 117, 1.0)),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(143, 148, 251, .2),
              blurRadius: 20.0,
              offset: Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.grey[600])
            ),
          ),
          Divider(
            color: Colors.grey[600],
            thickness: 1,
            indent: 2,
            endIndent: 2,
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Senha",
                hintStyle: TextStyle(color: Colors.grey[600])
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: 1900),
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadVouchersPage()),
            );
          },
          child: Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Usar biometria"),
        Switch(
          value: _isUsingBiometrics,
          onChanged: (value) {
            setState(() => _isUsingBiometrics = value);
            if (value) {
              _authenticateWithBiometrics();
            }
          },
        ),
      ],
    );
  }
}
