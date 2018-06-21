/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Gonzalo
 * Creation Date: 24-08-2017 at 15:27:46
 *********************************************/
int N=...;		//Number of nodes
int K=...;		//Number of vehicle
float V=...;	//Capacity of vehicle
int P=...;		//Number of product 
int D=...;		//Number of depot

range nodes=1..N;
range city=(D+1)..N;
range depot=1..D;
range vehicle=1..K;
range product=1..P;



tuple Vec {int i; int j;}
{Vec} Arcs={<i,j> | i in nodes , j in nodes};

tuple Vec_2 {int i; int j; int k;}
{Vec_2} Arcs_2={<i,j,k> | i in nodes , j in nodes, k in vehicle}; 

tuple Vec_3 {int i; int p; int k;}
{Vec_3} Arcs_3={<i,p,k> | i in nodes , p in product, k in vehicle};

tuple Vec_4 {int i; int p;}
{Vec_4} Arcs_4={<i,p> | i in city , p in product};

tuple Vec_5 {int i; int k;}
{Vec_5} Arcs_5={<i,k> | i in nodes , k in vehicle};

int d[Arcs_4]=...;		// Demand of costumer i by product p 
float c[Arcs]=...;		//Cost to travel from city i to j
float v[product]=...;	//Capacidad requerida del producto P
int g[depot]=...;		// Vehicle per depot

//Model 
//Definition of Variable
dvar boolean x[Arcs_2]; 	//1 if vehicle k travel from i to j
dvar int+ z [Arcs_3];		//The amount of product p deliver to city i by vehicle k
dvar int+ u[Arcs_5];		// ranking in visit every city
dvar int+ f[Arcs_5];			//Almacen de origen de camion k que visita ciudad i
dvar int+ F;			

//Objective Function
minimize F;

//Constrains
subject to{
sum (k in vehicle, i in nodes, j in nodes)c[<i,j>]*x[<i,j,k>]==F;

forall ( d in depot)
sum (j in nodes, k in vehicle:<j,k> in Arcs_5) x[<d,j,k>] == g[d];

forall ( d in depot)
sum (j in nodes, k in vehicle:<j,k> in Arcs_5) x[<j,d,k>] == g[d];

forall (d in depot, b in depot, k in vehicle: <d,b,k> in Arcs_2)
  x[<d,b,k>]==0 ; 
  
forall(i in city)
  sum(k in vehicle, j in nodes:<i,j,k> in Arcs_2)x[<i,j,k>]>=1;	
  
forall(i in city, k in vehicle)
  sum(j in nodes)x[<i,j,k>]-sum(j in nodes)x[<j,i,k>]==0;

forall(i in city, p in product)
  sum (k in vehicle)z[<i,p,k>]==d[<i,p>];
  
forall (i in city, k in vehicle, p in product)
  z[<i,p,k>]<=d[<i,p>]*sum(j in nodes)x[<i,j,k>];
  
forall (k in vehicle)
  sum(p in product, i in city)z[<i,p,k>]*v[p]<=V;  
 
//SEC  
forall(d in depot, j in nodes, k in vehicle)
  u[<j,k>]>=x[<d,j,k>];

forall(i in city, k in vehicle, j in city)
  u[<i,k>]+1 <= u[<j,k>]+1000*(1-x[<i,j,k>]);
  
forall(i in nodes, k in vehicle)
  1<=u[<i,k>]<=N-D;   
  
// Fixed-Destination
forall (d in depot, k in vehicle)
  f[<d,k>]==d;
  
forall (i in nodes, j in nodes, k in vehicle)  
  f[<i,k>]-f[<j,k>]+(D-1)*x[<i,j,k>]<=D-1;
  
forall (i in city, k in vehicle)
  f[<i,k>]>=0  ; 


	   
}

 