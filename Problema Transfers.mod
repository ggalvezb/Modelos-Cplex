/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Carolina
 * Creation Date: 29-05-2018 at 0:02:28
 *********************************************/
//Sets 
int N=...;


//Rangos
range Nodes=0..N+1;
range Pasajeros=1..N;

tuple Arc {int i; int j;}
{Arc} Arcs ={<i,j> | i in Nodes, j in Nodes}; 

//Parametros
int M=...;
int capacidad=...;
int t[Arcs]=...;
int a[Pasajeros]=...;
int b[Pasajeros]=...;
int c[Pasajeros]=...;
int d[Pasajeros]=...;


//Variables
dvar boolean x[Arcs];
dvar boolean z[Pasajeros];
dvar int+ s[Nodes];
dvar int+ L;
dvar int+ U;


//Función Objetivo
maximize sum (i in Pasajeros) z[i];

subject to {
sum (i in Pasajeros) z[i]<=capacidad;		//1
forall (i in Nodes,j in Nodes: j!=0) s[i]+t[<i,j>]<=s[j]+M*(1-x[<i,j>]); //2
forall (i in Pasajeros) a[i]<=s[i]; // 3
forall (i in Pasajeros) s[i]<=b[i]; //4
forall (i in Pasajeros) s[N+1]>=x[<i,N+1>]*t[<i,N+1>]+s[i]; //5
sum (i in Pasajeros) x[<0,i>]==1;				//6
sum (i in Pasajeros) x[<i,N+1>]==1;				//7
forall (j in Pasajeros) sum(i in Nodes:i!=N+1) x[<i,j>] - sum(i in Nodes:i!=0) x[<j,i>]==0; //8
forall (i in Pasajeros) z[i] == sum(j in Nodes: j!=N+1) x[<j,i>]; //9
L<=s[N+1];//10
s[N+1]<=U;//11
forall(i in Pasajeros) c[i]*z[i]<=L;//12
forall(i in Pasajeros) U<=d[i]+M*(1-z[i]);  //13
}


