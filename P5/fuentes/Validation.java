
import java.util.*; 

import java.io.IOException; 

import org.apache.hadoop.fs.Path; 
import org.apache.hadoop.conf.*; 
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hdfs.DFSClient.Conf;
import org.apache.hadoop.io.*; 
import org.apache.hadoop.mapred.*; 
import org.apache.hadoop.util.*;



public class Validation {
	
	public static void main [](){
		String strFile2 = "tetha.csv";
		CSVReader tethar = new CSVReader(new FileReader(strFile2));
		Double[] tetha = new Double[1601];
		tetha = tethar.readNext;
		tethar.close();
			    
		String strFile = "dataTest.csv";
		CSVReader reader = new CSVReader(new FileReader(strFile));
		String [] nextLine = new String[1601];
		int lineNumber = 0;
		
		/**
		 * Resultados
		 */
		int aBien = 0;
		int aMal = 0;
		int bBien = 0;
		int bMal = 0;
    
		while ((nextLine = reader.readNext()) != null) {
			lineNumber++;
			String letra = nextLine[1].toString(); //grupo A o B
			
			int aux = 0;
			double z = 0.0;
			double dato = 0;
			for (int i=2; i<nextLine.length; i++) {
				aux = i - 1;
				dato = Double.parseDouble(nextLine[i]);
				z+=dato*tetha[aux];
			}
			double fx = (1/1+Math.exp(-z));
			if(letra.equals("A")){
				if(fx<0.5){
					aBien++;
				}
				else bMal++;
			}
			else{
				if(fx<0.5){
					aMal++;
				}
				else bBien++;
			}
			System.out.println("	A		B");
			System.out.println("A	"+aBien+("	")+bMal);
			System.out.println("B	"+aMal+("	")+bBien);
		}
		reader.close();
		    
	}
}	
