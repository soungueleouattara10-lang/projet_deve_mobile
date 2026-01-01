import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = ""; // Expression affichée en haut
  String display = "0";   // Résultat / nombre courant
  bool justEvaluated = false;

  static const Color bgBlack = Colors.black;
  static const Color btnGray = Color(0xFF333333);
  static const Color btnOrange = Color(0xFFFF9F0A);
  String toDisplayExpression(String exp) {
    return exp.replaceAll("*", "×");
  }

  // =====================CALCUL =================
  void evaluate() {
    try {
      String exp = expression;

      // Si l'expression se termine par un opérateur, on ajoute display
      if (exp.isEmpty || _endsWithOperator(exp)) {
        exp += display;
      }
//conversion des valeurs des boutons operateurs en expression mathematiques
      exp = exp
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("%", "/100")
          .trim();

      Parser parser = Parser();
      Expression parsed = parser.parse(exp);
      double result =
      parsed.evaluate(EvaluationType.REAL, ContextModel());

      final resultStr = result % 1 == 0
          ? result.toInt().toString()
          : result
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');

      setState(() {
        expression = "$exp =";
        display = resultStr;
        justEvaluated = true;
      });
    } catch (e) {
      setState(() {
        display = "Erreur";
      });
    }
  }

  bool _endsWithOperator(String exp) {
    return exp.trim().endsWith("+") ||
        exp.trim().endsWith("-") ||
        exp.trim().endsWith("×") ||
        exp.trim().endsWith("÷");
  }



  // ================= GESTION DES BOUTONS  =================
  void onPress(String value) {
    setState(() {
      if (value == "C") {
        expression = "";
        display = "0";
        justEvaluated = false;
      }

      else if (value == "=") {
        if (display != "Erreur") {
          evaluate();
        }
      }
//gestion  boutons operateurs
      else if (["+", "-", "×", "÷"].contains(value)) {
        if (justEvaluated) {
          expression = "$display $value ";
          justEvaluated = false;
        } else {
          expression += "$display $value ";
        }
        display = "0";
      }
// gestion boutons .
      else if (value == ".") {
        if (!display.contains(".")) {
          display += ".";
        }
      }
//gestion  bouton +/-
      else if (value == "+/-") {
        if (display.startsWith("-")) {
          display = display.substring(1);
        } else if (display != "0") {
          display = "-$display";
        }
      }
//gestion bouton % implementé en pourcentage
      else if (value == "%") {
        double n = double.tryParse(display) ?? 0;
        display = (n / 100).toString();
      }

      else {
        if (display == "Erreur" || justEvaluated) {
          display = value;
          justEvaluated = false;
          expression = "";
        } else if (display == "0") {
          display = value;
        } else {
          display += value;
        }
      }
    });
  }

  // ================= BOUTON =================
  Widget calcButton(
      String text, {
        Color color = btnGray,
        double fontSize = 30,
      }) {
    return GestureDetector(
      onTap: () => onPress(text),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      body: SafeArea(
        child: Column(
          children: [
            // ===== AFFICHAGE =====
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      toDisplayExpression(expression),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 24,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ===== CLAVIER =====
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _row(["C", "%", "÷"],
                              [btnGray , btnGray , btnOrange]),
                          _row(["7", "8", "9"]),
                          _row(["4", "5", "6"]),
                          _row(["1", "2", "3"]),
                          _row(["+/-", "0", "."]),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: calcButton("×", color: btnOrange)),
                          Expanded(child: calcButton("-", color: btnOrange)),
                          Expanded(child: calcButton("+", color: btnOrange)),
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () => onPress("="),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: btnOrange,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "=",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LIGNE DE BOUTONS =================
  Widget _row(List<String> texts, [List<Color>? colors]) {
    return Expanded(
      child: Row(
        children: List.generate(texts.length, (i) {
          return Expanded(
            child: calcButton(
              texts[i],
              color: colors != null ? colors[i] : btnGray,
            ),
          );
        }),
      ),
    );
  }
}
