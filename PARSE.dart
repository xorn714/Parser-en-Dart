import 'dart:io';

/*
Hecho por:
Bach. Daniel Hernández
30.870.923
maureradaniel.2005@gmail.com
*/

class Token {
  final String type;
  final String value;
  final int line;
  final int column;

  Token(this.type, this.value, this.line, this.column);

  @override
  String toString() => 'Token($type, $value) at line $line, column $column';
}

//Se va a encargar de convertir el pseudocdigo en en tokens para ser una representacion lexica
class Lexer {
  final String input;
  int position = 0;
  int line = 1;
  int column = 1;

  Lexer(this.input);//constructor

  Token nextToken()//devolvera el siguiente token y manejara los espacios y saltos de linea
  {
    if (position >= input.length) return Token('EOF', '', line, column); 

    while (position < input.length && (input[position] == ' ' || input[position] == '\t')) {
      position++;
      column++;
      if (position >= input.length) return Token('EOF', '', line, column);
    }

    if (input[position] == '\n') {
      position++;
      line++;
      column = 1;
      return Token('NEWLINE', '\n', line, column);
    }

    if (input.startsWith('//', position)) {
      while (position < input.length && input[position] != '\n') {
        position++;
        column++;
      }
      return nextToken();
    }

    final char = input[position];

    if (RegExp(r'\d').hasMatch(char)) {
      final start = position;
      final startColumn = column;
      while (position < input.length && RegExp(r'\d').hasMatch(input[position])) {
        position++;
        column++;
      }
      return Token('NUMBER', input.substring(start, position), line, startColumn);
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
      final start = position;
      final startColumn = column;
      while (position < input.length && RegExp(r'[a-zA-Z]').hasMatch(input[position])) {
        position++;
        column++;
      }
      final value = input.substring(start, position);
      switch (value) {
        case 'Algoritmo':
        case 'Declaracion':
        case 'Variables':
        case 'Inicio':
        case 'Fin':
        case 'LEER':
        case 'ESCRIBIR':
        case 'PARA':
        case 'FPARA':
        case 'REPETIR':
        case 'HASTA':
          return Token('KEYWORD', value, line, startColumn);
        case 'SI':
          return Token('SI', value, line, startColumn);
        case 'SINO':
          return Token('SINO', value, line, startColumn);
        case 'FSI':
          return Token('FSI', value, line, startColumn);
        case 'MIENTRAS':
          return Token('MIENTRAS', value, line, startColumn);
        case 'FMIENTRAS':
          return Token('FMIENTRAS', value, line, startColumn);
        case 'entero':
        case 'real':
        case 'booleano':
        case 'caracter':
        case 'cadena':
          return Token('TYPE', value, line, startColumn);
        case 'VERDADERO':
        case 'FALSO':
          return Token('BOOLEAN', value, line, startColumn);
        default:
          return Token('IDENTIFIER', value, line, startColumn);
      }
    }

    switch (char) {
      case '+':
        position++;
        column++;
        return Token('PLUS', '+', line, column - 1);
      case '-':
        position++;
        column++;
        return Token('MINUS', '-', line, column - 1);
      case '*':
        position++;
        column++;
        return Token('MULT', '*', line, column - 1);
      case '/':
        position++;
        column++;
        return Token('DIV', '/', line, column - 1);
      case '=':
        position++;
        column++;
        if (position < input.length && input[position] == '=') {
          position++;
          column++;
          return Token('EQ', '==', line, column - 2);
        }
        return Token('ASSIGN', '=', line, column - 1);
      case '<':
        position++;
        column++;
        if (position < input.length && input[position] == '=') {
          position++;
          column++;
          return Token('LE', '<=', line, column - 2);
        } else if (position < input.length && input[position] == '>') {
          position++;
          column++;
          return Token('NE', '<>', line, column - 2);
        }
        return Token('LT', '<', line, column - 1);
      case '>':
        position++;
        column++;
        if (position < input.length && input[position] == '=') {
          position++;
          column++;
          return Token('GE', '>=', line, column - 2);
        }
        return Token('GT', '>', line, column - 1);
      case ';':
        position++;
        column++;
        return Token('SEMICOLON', ';', line, column - 1);
      case '"':
        final start = position;
        final startColumn = column;
        position++;
        column++;
        while (position < input.length && input[position] != '"') {
          position++;
          column++;
        }
        if (position < input.length) {
          position++;
          column++;
        }
        return Token('STRING', input.substring(start, position), line, startColumn);
      case '(':
        position++;
        column++;
        return Token('LPAREN', '(', line, column - 1);
      case ')':
        position++;
        column++;
        return Token('RPAREN', ')', line, column - 1);
      case '{':
        position++;
        column++;
        return Token('LBRACE', '{', line, column - 1);
      case '}':
        position++;
        column++;
        return Token('RBRACE', '}', line, column - 1);
      default:
        throw Exception('Unknown character: $char at line $line, column $column');
    }
  }
}

//esta clase analiza la secuencia de los tokens del lexer y construye la representacion del codigo
class Parser {
  final Lexer lexer;
  late Token currentToken;
  final SymbolTable symbolTable = SymbolTable();
  List<String> coldRunOutput = [];

//constructor
  Parser(this.lexer) {
    currentToken = lexer.nextToken();
  }

//función para avanzar al siguiente token y si no lanza una excepción
  void eat(String tokenType) {
    if (currentToken.type == tokenType) {
      currentToken = lexer.nextToken();
    } else {
      throw Exception('Error: Se esperaba $tokenType pero se encontró ${currentToken.type} en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
  }

//función principal del analisis sintáctico del codigo
  void parse() {
    while (currentToken.type != 'EOF') {
      if (currentToken.type == 'KEYWORD' || currentToken.type == 'NEWLINE') {
        currentToken = lexer.nextToken();
        continue;
      }
      if (currentToken.type == 'SI') {
        parseIfStatement();
      } else if (currentToken.type == 'MIENTRAS') {
        parseWhileStatement();
      } else if (currentToken.type == 'PARA') {
        parseForStatement();
      } else if (currentToken.type == 'REPETIR') {
        parseRepeatStatement();
      } else {
        parseStatement();
      }
    }
  }

  void parseIfStatement() {
    eat('SI');
    eat('LPAREN');
    dynamic condition = parseExpression();
    eat('RPAREN');
    coldRunOutput.add("Evaluando condición SI: $condition");
    eat('LBRACE');
    while (currentToken.type != 'RBRACE') {
      parseStatement();
    }
    eat('RBRACE');
    if (currentToken.type == 'SINO') {
      eat('SINO');
      coldRunOutput.add("Condición SI falsa, ejecutando bloque SINO");
      eat('LBRACE');
      while (currentToken.type != 'RBRACE') {
        parseStatement();
      }
      eat('RBRACE');
    }
    if (currentToken.type != 'FSI') {
      throw Exception('Error: Se esperaba FSI para cerrar el bloque SI en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
    eat('FSI');
  }

  void parseWhileStatement() {
    eat('MIENTRAS');
    eat('LPAREN');
    dynamic condition = parseExpression();
    eat('RPAREN');
    coldRunOutput.add("Evaluando condición MIENTRAS: $condition");
    eat('LBRACE');
    while (currentToken.type != 'RBRACE') {
      parseStatement();
    }
    eat('RBRACE');
    if (currentToken.type != 'FMIENTRAS') {
      throw Exception('Error: Se esperaba FMIENTRAS para cerrar el bloque MIENTRAS en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
    eat('FMIENTRAS');
  }

//Analiza y ejecuta una instrucción
  void parseForStatement() {
    eat('PARA');
    eat('LPAREN');
    parseAssignment();
    eat('SEMICOLON');
    dynamic condition = parseExpression();
    eat('SEMICOLON');
//tuve bastantes problemas con este ciclo
    String updateVarName = currentToken.value;
    eat('IDENTIFIER');
    eat('ASSIGN');
    dynamic updateValue = parseExpression();
    eat('RPAREN');
    
    coldRunOutput.add("Evaluando ciclo PARA: $condition");
    eat('LBRACE');
    
    while (evaluateCondition(condition)) {
        parseStatement();
        symbolTable.set(updateVarName, updateValue);
        condition = parseExpression();
    }
    eat('RBRACE');
    
    if (currentToken.type != 'FPARA') {
      throw Exception('Error: Se esperaba FPARA para cerrar el bloque PARA en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
    eat('FPARA');
  }

  bool evaluateCondition(dynamic condition) {
      return condition;
  }

  void parseRepeatStatement() {
    eat('REPETIR');
    coldRunOutput.add("Ejecutando ciclo REPETIR");
    eat('LBRACE');
    while (currentToken.type != 'RBRACE') {
      parseStatement();
    }
    eat('RBRACE');
    if (currentToken.type != 'HASTA') {
      throw Exception('Error: Se esperaba HASTA para cerrar el bloque REPETIR en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
    eat('HASTA');
    eat('LPAREN');
    dynamic condition = parseExpression();
    eat('RPAREN');
    coldRunOutput.add("Evaluando condición HASTA: $condition");
  }

  void parseStatement() {
    print('parseStatement: currentToken=$currentToken');
    if (currentToken.type == 'KEYWORD' && (currentToken.value == 'Algoritmo' || currentToken.value == 'Declaracion' || currentToken.value == 'Variables' || currentToken.value == 'Inicio' || currentToken.value == 'Fin')) {
      currentToken = lexer.nextToken();
    } else if (currentToken.type == 'IDENTIFIER') {
      String varName = currentToken.value;
      eat('IDENTIFIER');
      if (currentToken.type == 'ASSIGN') {
        eat('ASSIGN');
        dynamic value = parseExpression();
        symbolTable.set(varName, value);
        coldRunOutput.add("Asignación: $varName = $value");
      } else if (currentToken.type == 'NEWLINE') {
        currentToken = lexer.nextToken();
      } else {
        throw Exception('Error: Se esperaba ASSIGN pero se encontró ${currentToken.type} en la línea ${currentToken.line}, columna ${currentToken.column}');
      }
    } else if (currentToken.type == 'TYPE') {
      eat('TYPE');
      while (currentToken.type == 'IDENTIFIER') {
        String varName = currentToken.value;
        eat('IDENTIFIER');
        symbolTable.set(varName, null); // Inicializa las variables en la tabla de símbolos
        coldRunOutput.add("Declaración de variable: $varName");
        if (currentToken.type == 'COMMA') {
          eat('COMMA');
        } else {
          break;
        }
      }
    } else if (currentToken.type == 'NEWLINE') {
      currentToken = lexer.nextToken();
    } else if (currentToken.type == 'KEYWORD' && currentToken.value == 'ESCRIBIR') {
      eat('KEYWORD');
      final value = parseExpression();
      coldRunOutput.add("Salida: $value");
      print(value);
    } else if (currentToken.type == 'KEYWORD' && currentToken.value == 'LEER') {
      eat('KEYWORD');
      if (currentToken.type == 'IDENTIFIER') {
        String varName = currentToken.value;
        eat('IDENTIFIER');
        print('Ingrese un valor para $varName:');
        String? input = stdin.readLineSync();
        symbolTable.set(varName, int.tryParse(input!) ?? input);
        coldRunOutput.add("Entrada: $varName = ${symbolTable.get(varName)}");
      }
    } else {
      parseExpression();
    }
  }

//analiza y ejecuta una asignación
  dynamic parseAssignment() {
    String varName = currentToken.value;
    eat('IDENTIFIER');
    if (currentToken.type == 'ASSIGN') {
      eat('ASSIGN');
      dynamic value = parseExpression();
      symbolTable.set(varName, value);
      coldRunOutput.add("Asignación en ciclo: $varName = $value");
      return value;
    } else {
      throw Exception('Error: Se esperaba ASSIGN pero se encontró ${currentToken.type} en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
  }

//analiza y evalúa una expresión
  dynamic parseExpression() {
    dynamic left = parseTerm();

    while (currentToken.type == 'PLUS' || currentToken.type == 'MINUS' ||
          currentToken.type == 'MULT' || currentToken.type == 'DIV' ||
          currentToken.type == 'LT' || currentToken.type == 'GT' ||
          currentToken.type == 'LE' || currentToken.type == 'GE' ||
          currentToken.type == 'EQ' || currentToken.type == 'NE') {
      String op = currentToken.type;
      eat(currentToken.type);
      dynamic right = parseTerm();
      left = applyOperator(op, left, right);
    }

    return left;
  }

//analiza y evalua un termino
  dynamic parseTerm() {
    if (currentToken.type == 'IDENTIFIER') {
      String varName = currentToken.value;
      eat('IDENTIFIER');
      return symbolTable.get(varName);
    } else if (currentToken.type == 'NUMBER') {
      String value = currentToken.value;
      eat('NUMBER');
      return int.parse(value);
    } else if (currentToken.type == 'BOOLEAN') {
      String value = currentToken.value;
      eat('BOOLEAN');
      return value == 'VERDADERO';
    } else if (currentToken.type == 'STRING') {
      String value = currentToken.value;
      eat('STRING');
      return value;
    } else {
      throw Exception('Expresión inválida en la línea ${currentToken.line}, columna ${currentToken.column}');
    }
  }
//si llegaste aqui lo admiro mucho profe

//aplica un operador a dos operandos
    dynamic applyOperator(String op, dynamic left, dynamic right) {
    switch (op) {
      case 'PLUS':
        return left + right;
      case 'MINUS':
        return left - right;
      case 'MULT':
        return left * right;
      case 'DIV':
        return left / right;
      case 'LT':
        return left < right;
      case 'GT':
        return left > right;
      case 'LE':
        return left <= right;
      case 'GE':
        return left >= right;
      case 'EQ':
        return left == right;
      case 'NE':
        return left != right;
      default:
        throw Exception('Operador no soportado: $op');
    }
  }

//hace la corrida en frio
  void runColdRun() {
    print("\nCorrida en frío del pseudocódigo:\n");
    for (String output in coldRunOutput) {
      print(output);
    }
  }
}

//mantiene el registro de las variables y sus valores en contexto del pseudocodigo
class SymbolTable {
  final Map<String, dynamic> _table = {};

//establece el valor a una variable
  void set(String name, dynamic value) {
    _table[name] = value;
  }

//devuelve el valor de una variable o lanza una excepcion si no esta definida
  dynamic get(String name) {
    if (!_table.containsKey(name)) {
      throw Exception('Variable $name no definida');
    }
    return _table[name];
  }
}

//se explica por si solo la funcion principal la cual ejecuta el programa

/*
  para correr el programa en la consola debe ingresar "dart PARSE.dart NombreDelArchivo.pse
  esta validado para que en caso de no poder poner el archivo te salte un error
*/
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Por favor, proporciona el nombre del archivo como argumento.');
    return;
  }

  final filename = arguments[0];
  final file = File(filename);
  
  if (!file.existsSync()) {
    print('El archivo $filename no existe.');
    return;
  }

  final content = file.readAsStringSync();
  final lexer = Lexer(content);
  final parser = Parser(lexer);

  try {
    parser.parse();
    print('El pseudocódigo se ha interpretado correctamente.');
    print('Variables: ${parser.symbolTable}');
    parser.runColdRun();
  } catch (e) {
    print('Error al interpretar el pseudocódigo: $e');
  }
}

/*
  y con esto muchisimas gracias por corregir este codigo
*/