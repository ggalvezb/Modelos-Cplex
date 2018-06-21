/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Gonzalo
 * Creation Date: 13-11-2017 at 19:33:41
 *********************************************/
int N=...; //Numero de nodos
int D=...; //numero de depositos
int K=...; //Numero de vehiculos disponibles

range nodos=1..N;
range clientes= (D+1)..N;
range vehiculos=1..K;

tuple Vec {int i; int j;}
{Vec} Arcs={<i,j> | i in nodos, j in nodos};

tuple Vec_2 {int i; int j; int k;}
{Vec_2} Arcs_2={<i,j,k> | i in nodos, j in nodos, k in vehiculos};

tuple Vec_3 {int i; int k;}
{Vec_3} Arcs_3={<i,k> | i in nodos, k in vehiculos};

tuple Vec_4 {int i; int k;}
{Vec_4} Arcs_4={<i,k> | i in clientes, k in vehiculos};

//Parametros
int f=...;                     //Costo de transporte
int dem[clientes]=...;         //Demanda del cliente j
float ST[clientes]=...;                 //Tiempo de servicio
float d[Arcs]=...;             //Distancia en kilometros entre i,j
float t[Arcs]=...;            //Distancia en tiempo entre i,j
int C=...;                    //Capacidad del vehiculo
int O[clientes]=...;        //Hora de apertura del cliente j
int Cl[clientes]=...;        //Hora de cierre del cliente j

//Variables de Decision
dvar boolean x[Arcs_2];
dvar boolean y[Arcs_3];
dvar float h[Arcs_4];        //inicio del servicio en cliente i por vehiculo k
dvar int+ z[Arcs_2];

//Funcion objetivo
minimize (sum(k in vehiculos, j in nodos, i in nodos)d[<i,j>]*x[<i,j,k>])*f;

subject to{

sum(k in vehiculos, j in clientes)x[<1,j,k>]==K;

sum(k in vehiculos, j in clientes)x[<j,1,k>]==K;

forall(k in vehiculos)
  sum( j in clientes)x[<1,j,k>]<=1;

forall(i in clientes)
  sum(k in vehiculos)y[<i,k>]==1;

forall(i in clientes, k in vehiculos)
  sum(j in nodos)x[<i,j,k>]==y[<i,k>];

forall(i in clientes, k in vehiculos)
  sum(j in nodos)x[<j,i,k>]==y[<i,k>];


forall(i in nodos, j in nodos, k in vehiculos)
  z[<i,j,k>]<=C*x[<i,j,k>];

forall(i in clientes)
  sum(k in vehiculos, j in nodos:i!=j)z[<i,j,k>]-sum(k in vehiculos, j in nodos:i!=j)z[<j,i,k>]==dem[i];

forall(i in clientes, j in clientes, k in vehiculos)
  h[<i,k>]+ST[i]+t[<i,j>]<=h[<j,k>]+(1-x[<i,j,k>])*1000000000;

forall(i in clientes, k in vehiculos)
  O[i]<=h[<i,k>];

 forall(i in clientes, k in vehiculos)
  h[<i,k>]<=Cl[i];

}