import 'package:bdProject/bdProject.dart' as bd;
import 'package:sqljocky5/sqljocky.dart';

void main() async {
  // ignore: omit_local_variable_types
  MySqlConnection conn = await bd.createConnection();
  
  await bd.dropTables(conn);
  await bd.dropBD2(conn);

  await bd.createTables(conn);
  await bd.insertData(conn);
  await bd.createBD2(conn);
  await bd.useProcedure(conn);

  await bd.listData(conn, 'produto');
  await new Future.delayed(const Duration(seconds : 2));
  await bd.listData(conn, 'todasAsPessoas');
  await new Future.delayed(const Duration(seconds : 2));
  await bd.listHistorico(conn, 'historicoProdutos');


  await conn.close();
}