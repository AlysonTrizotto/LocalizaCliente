// @dart=2.9
//Apresentando Layout -
import 'package:flutter/material.dart';
import 'package:localiza_favoritos/componentes/tema.dart';
import 'package:splashscreen/splashscreen.dart';
import 'screens/dashboard/inicio.dart';

void main() async {
  runApp(CLHApp());
}

// ignore: use_key_in_widget_constructors
class CLHApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: localizaTema,
      debugShowCheckedModeBanner: false,
      home: const MySplashScreen(),
      //home: FormularioCadastro(0.0,0.0),
      /*home:  AnimatedSplashScreen(
            duration: 3000,
            splash: Icons.home,
            nextScreen: dashboard(0),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.rotate,
            backgroundColor: Colors.blue),
*/

      routes: {
        '/retornoEditaFavorios': (BuildContext context) => const Dashboard(1),
      },
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() {
    return MySlpashScreenState();
  }
}

class MySlpashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    return _splash();
  }
}

Widget _splash() {
  return Stack(
    children: <Widget>[
      SplashScreen(
        seconds: 5,
        gradientBackground: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xffED213A), Color(0xff93291E)],
        ),
        navigateAfterSeconds:  const Dashboard(0),
        loaderColor: Colors.amberAccent,
      ),
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagem/screenshot/screenPedro.jpg'),
            fit: BoxFit.none,
          ),
          ),
        ),
    ],
  );
}
