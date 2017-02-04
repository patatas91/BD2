import java.io.File;
import java.io.IOException;
import java.util.NavigableMap;
import java.util.Scanner;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class Logistic {
		

	//Clase mapper

	public static class DataMapper extends TableMapper<IntWritable,
	DoubleWritable> /* Tipo de valor de salida(valor de j,valorIntermedio)*/
	{
		
		private double[] tetha = new double[1601]; // Vector para el calculo de los 1601 valores que permiten aproximar la clasificacion de un dato
		private double[] aux = new double[1601]; /*Estructura auxiliar que se le pasa al cleanup*/
		
		@Override 
		public void setup(Context context) {
			/*Devuelve la configuracion del contexto*/
			Configuration c = context.getConfiguration();
			/*Asigna las variables del contexto(MapReduce) al vector result*/
			for(int i=0;i<tetha.length;i++){
				tetha[i]= c.getDouble("tetha"+i,0.0);
			}
		}

		/**
		 * @param row Valor actual de la clave de cada fila(registro)
		 * @param value Las columnas
		 * @param context El contexto actual
		 * @throws IOException 
		 * @throws InterruptedException 
		 * @see org.apache.hadoop.mapreduce.Mapper#map(KEYIN, VALUEIN,
		 * org.apache.hadoop.mapreduce.Mapper.Context)
		 */
		@Override
		public void map(ImmutableBytesWritable row,Result value,Context context){
			double y = 1.0;
			/*Valor de y(entero) despues de comprobar a que grupo pertenece el dato perteneciente a row*/
			if(Bytes.toString(value.getValue(Bytes.toBytes("user"), Bytes.toBytes("grupo"))).equals("A")){
				y = 0.0;
			}   
		    
			/*Calculo de la funcion g(0*Xi)*/

			double z = 0.0;
			double g = 0.0;
			
			/*Calculamos el valor del dato xi en este caso llamado [x]*/
			double[] x = new double[1601];
			x[0] = 1.0;

		    NavigableMap<byte[], byte[]> familyMap = value.getFamilyMap(Bytes.toBytes("datos"));
		      for(byte[] bQunitifer : familyMap.keySet())
		      {
		         x[Integer.parseInt(Bytes.toString(bQunitifer))]  = 1.0;

		      }
			/*Calculo de tetha*Xi */
			for(int i=0;i<x.length;i++){
				z +=  tetha[i]* x[i];
			}
			/*Calculo de g(0x)*/
			g = (1/1+Math.exp(-z));
			/*Calculo de g(0x)-y*/
			g = g-y;
			
			/*Y multiplicamos por cada xij*/
			for(int j=0;j<aux.length;j++){
				aux[j] += g*x[j];
			}
		}
		/* El cleanup le pasa al reducer el par <j,'valorIntermedioParaJ'> que estaba almacenado en un vector
		 * auxiliar llamado aux */
		@Override
		public void cleanup(Context context) throws IOException, InterruptedException{
			for(int j=0;j<1601;j++){
				context.write(new IntWritable(j),new DoubleWritable(aux[j]));
			}
		}

	}
	// Clase reducer

	public static class DataReducer extends Reducer<
	IntWritable,			// Tipo de clave de entrada
	DoubleWritable, 		// Tipo de valor de entrada
	IntWritable,			// Tipo de clave de salida
	DoubleWritable>			// Tipo de valor de salida
	{
		public void reduce(IntWritable j ,Iterable<DoubleWritable> values, Context context)  {
			/*Se acumula en suma el valor de cada resultado intermedio que ha generado el map*/
			double suma = 0.0;
			for(DoubleWritable val: values ){
					suma += val.get();
			}
			try {
				// Se escribira en el fichero el par <j,'resultadoTotalParacadaj'> 
				context.write(j, new DoubleWritable(suma));
			} catch (IOException | InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	public static void main(String[] args) throws Exception{
		int convergencia = 0;
		double[] tetha = new double[1601];
		while(convergencia<5){
			Configuration conf = HBaseConfiguration.create();
			for(int i=0;i<tetha.length;i++){
				tetha[i]= conf.getDouble("tetha"+i,0.0);
			}
			Job job = Job.getInstance(conf,"Regresion logistica");
			Scan scan = new Scan();
			scan.setCaching(500);
			job.setJarByClass(Logistic.class);
			//Definir scan para leer la tabla

			job.setJarByClass(Logistic.class);
			TableMapReduceUtil.initTableMapperJob(
					"practica5", 				//nombre de la tabla
					scan,						// Instancia scan para controlar CF y atributos
					DataMapper.class,			// Clase mapper
					IntWritable.class,			// Tipo de clave de salida del mapper
					DoubleWritable.class,		// Tipo de valor de salida del mapper
					job);
			job.setReducerClass(DataReducer.class); // clase reducer
			job.setNumReduceTasks(6); // al menos una, ajustar si se requiere
			job.setOutputKeyClass(IntWritable.class);
			job.setOutputValueClass(DoubleWritable.class);

			FileOutputFormat.setOutputPath(job, new Path("out"));

			if (!job.waitForCompletion(true))
				return;
			for(int i=0;i<tetha.length;i++){
				tetha[i]= conf.getDouble("tetha"+i,0.0);
			}
			
			Scanner recorrerFichero = new Scanner(new File("out/part-r-00000"));
			String linea ="";
			while(recorrerFichero.hasNextLine()){
				int j = recorrerFichero.nextInt();
				double valor = recorrerFichero.nextDouble();
				tetha[j] = tetha[j] - 0.01*valor;
				recorrerFichero.nextLine();
				System.out.println(tetha[j]);
			}
			
			convergencia++;
			
		}
	}
}
