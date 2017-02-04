import java.io.IOException;

import java.io.FileReader;
import com.opencsv.CSVReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.TableExistsException;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.util.Bytes;

public class ImportFile{

	public static void main(String[] args) throws IOException
	{
		//CREA LA TABLA SI NO EXISTE
		try{
			/*Crea una instancia HBaseAdmin con la instancia de la configuracion*/
			Configuration config = HBaseConfiguration.create();
			HBaseAdmin hbase_admin = new HBaseAdmin( config );
			/*Crear descriptor de tabla*/
			HTableDescriptor htable = new HTableDescriptor("practica5"); 
			/*Crear descriptor de la familia de columnas*/
			HColumnDescriptor user = new HColumnDescriptor("user");
			HColumnDescriptor datos = new HColumnDescriptor("datos");
			/*Añadir familias de columnas a la tabla*/
			htable.addFamily(user);
			htable.addFamily(datos);
			System.out.println( "Connecting..." );
			System.out.println( "Creating Table..." );
			hbase_admin.createTable( htable );
			System.out.println("Done!");
		} catch(TableExistsException e){
			System.out.println("Ya existe la tabla practica5.");
		}

		//CONECTA CON LA TABLA
		org.apache.hadoop.conf.Configuration config = HBaseConfiguration.create();
		HTable table = new HTable(config, "practica5");

		//LEE EL FICHERO
		try {
			//csv file containing data
			String strFile = "data.csv";
			CSVReader reader = new CSVReader(new FileReader(strFile));
			String [] nextLine;
			int lineNumber = 0;
			//recorre cada linea
			while ((nextLine = reader.readNext()) != null) {

				lineNumber++;
				Put p = new Put(Bytes.toBytes("row"+lineNumber));
				System.out.println("Line # " + lineNumber);

				p.add(Bytes.toBytes("user"), Bytes.toBytes("uid"),Bytes.toBytes(nextLine[0])); //código unico de usuario
				p.add(Bytes.toBytes("user"),Bytes.toBytes("grupo"),Bytes.toBytes(nextLine[1])); //grupo A o B

				int aux;
				// nextLine[] is an array of values from the line
				// inserta cada característica
				for (int i=2; i<nextLine.length; i++) {
					aux = i - 1;
					if(Double.parseDouble(nextLine[i])==1.0){
						p.add(Bytes.toBytes("datos"), Bytes.toBytes(""+aux),Bytes.toBytes(nextLine[i]));
					}
				}	
				table.put(p);
			}
			reader.close();
		} catch(Exception e) {    	
			e.printStackTrace();
		}
	}

}