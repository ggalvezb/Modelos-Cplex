/*********************************************
 * OPL 12.7.1.0 Model
 * Author: ggalv
 * Creation Date: 24/4/2018 at 19:10:49
 *********************************************/
int N=...;
int p=...;					//Cantidad de centros a instalar

range nodos=1..N;

tuple Vec{int i; int j;}
{Vec} Arcs={<i,j>|i in nodos, j in nodos};

float c[nodos]=...;
float f[nodos]=...;
int d[nodos]=...;
int q[nodos]=...;
int g[nodos]=...;
int h[Arcs]=...;
int a[Arcs]=...;

dvar int+ y[nodos];
dvar int+ x[Arcs];
dvar boolean z[nodos];
dvar boolean w[nodos];


maximize sum(j in nodos)((g[j]*d[j]-c[j])*z[j])-(sum(j in nodos)f[j]*w[j]+sum(i in nodos, j in nodos)h[<i,j>]*x[<i,j>]);

subject to{

sum(j in nodos)z[j]==p;					//Restriccion (2)
 
forall(j in nodos)
  w[j]+z[j]<=1;  						//Restriccion (3)
  
forall(j in nodos)
  y[j]<=q[j]*w[j];						//Restriccion (4)
  
forall(j in nodos)
  sum(i in nodos)a[<i,j>]*x[<i,j>]-sum(i in nodos)a[<j,i>]*x[<j,i>]==d[j]*z[j]-y[j];			//Restriccion (5)				
      
}



