import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
                height: 370,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/lego.png'),
                        fit: BoxFit.fill
                    )
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        child: Container(
                            margin: const EdgeInsets.only(top: 300),
                            child: const Center(
                              child: Text("Login", style: TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),),
                            )
                        )
                    )
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          const BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .2),
                              blurRadius: 20.0,
                              offset: Offset(0,10)
                          )
                        ]
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: " Email or Phone number",
                                prefixIcon: const Icon(Icons.person, color: Colors.redAccent),
                                hintStyle: TextStyle(color: Colors.grey[500])
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.redAccent),
                                hintStyle: TextStyle(color: Colors.grey[500])
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(16, 20, 251, 1),
                              Color.fromRGBO(16, 20, 251, .6),
                            ]
                        )
                    ),
                    child: const Center(
                      child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(16, 20, 251, 1),
                              Color.fromRGBO(16, 20, 251, .6),
                            ]
                        )
                    ),
                    child: const Center(
                      child: Text("Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      // Remove this after testing is over
      bottomNavigationBar: BottomAppBar(  //nav bar to hold return button
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child : ElevatedButton( //return button
            child: const Text('Go back to home screen'),
            onPressed: () {
                Navigator.pop(context);
            },
          ),  //elevated button
          ),//container
      ),//container
      //Remove this section after testing is over
    );
  }
}