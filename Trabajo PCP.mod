/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Gonzalo
 * Creation Date: 25-09-2017 at 14:19:53
 *********************************************/
//Tarea PCP

//indices
int R=...;
int M=...;
int P=...;
int C=...;
int G=...;

//Sets
range recursos=1..R; // indice r
range meses=1..M; // indice t
range pres=1..P; //indice i
range colab=1..C; //indice k
range medicamentos=1..G;// indice g

//Arcos
tuple Vec {int i; int t;}
{Vec} Arcs={<i,t> | i in pres, t in meses};

tuple Vec_2 {int i; int k;}
{Vec_2} Arcs_2={<i,k> | i in pres, k in colab};

tuple Vec_3 {int k; int t;}
{Vec_3} Arcs_3={<k,t> | k in colab, t in meses};

tuple Vec_4 {int i; int r;}
{Vec_4} Arcs_4={<i,r> | i in pres, r in recursos};

tuple Vec_5 {int r; int t;}
{Vec_5} Arcs_5={<r,t> | r in recursos, t in meses};

tuple Vec_6 {int g; int t;}
{Vec_6} Arcs_6={<g,t> | g in medicamentos, t in meses};

tuple Vec_7 {int g; int i;}
{Vec_7} Arcs_7={<g,i> | g in medicamentos, i in pres};

//Parametros
int d[Arcs]=...; /*La cantidad pronosticada de demanda por prestaciones del tipo i durante el periodo t.*/
float c[Arcs_2]=...; /*La cantidad promedio de horas que utiliza cada prestación del tipo i de cada colaborador de tipo k.*/
int dtc[Arcs_3]=...;/*La cantidad total de horas disponible de cada colaborador de tipo k durante el periodo t.*/
float re[Arcs_4]=...;/*La cantidad promedio de horas que utiliza cada prestación del tipo i de cada recurso de tipo k.*/
int dtr[Arcs_5]=...; /*La cantidad total de horas disponible de cada recurso de tipo r durante el periodo t.*/
int sm[Arcs]=...; /*La cantidad mínima de prestaciones del tipo i a efectuar durante el periodo t.*/
int ttex[Arcs_5]=...; /*La cantidad extra total, expresada en horas, del recurso r disponible durante el periodo t.*/
int dp0[pres]=...;//prestaciones no efectuadas durante el periodo anterior al primero.
int compmax[Arcs_6]=...; //Maxima cantidad de medicamentos g que se pueden comprar en el mes t
int invini[medicamentos]=...; //Inventario inicial del medicamento m
int invmax[meses]=...; //Inventario maximo en el mes t
int alpha[Arcs_7]=...; //Cantidad de medicamento m usado en la prestacion i
int pprove[medicamentos]=...;
int pextra[medicamentos]=...;
int presup=...;
int costinv=...;
float porpresta=...;
float porpresup=...;
 
//Variables de decision
dvar int+ x[Arcs]; /*La cantidad mensual de prestaciones del tipo i que se efectúan durante el periodo t.*/
dvar int+ dp[Arcs]; /*La cantidad mensual de prestaciones del tipo i que no se pueden afectar durante el periodo t.*/
dvar float+ ex[Arcs_5]; /*La cantidad mensual de horas extra del recurso r que se requieren durante el periodo t.*/
dvar int+ inv[Arcs_6]; // Inventario del medicamento m en el mes t
dvar int+ dem[Arcs_6]; //Demanda del medicamento m en el mes t
dvar int+ comp[Arcs_6]; //Compra de medicamento m en periodo t
dvar int+ comptotal[Arcs_6];
dvar int+ compextra[Arcs_6];
dvar int+ F;
dvar int+ O;


maximize (porpresta*sum(i in pres, t in meses) x[<i,t>]-porpresup*sum(g in medicamentos,t in meses)(costinv*inv[<g,t>]+pprove[g]*comp[<g,t>]+pextra[g]*compextra[<g,t>]))	;

subject to{
	
	sum(i in pres, t in meses) x[<i,t>]==F;			 //Restriccion para encontrar las prestaciones
	
	sum(g in medicamentos,t in meses)(costinv*inv[<g,t>]+pprove[g]*comp[<g,t>]+pextra[g]*compextra[<g,t>])==O; //Restriccion para encontrar los costos
	
	forall(i in pres: i<=5) 						 //Restriccion 2
		x[<i,1>]==d[<i,1>]+dp0[i]-dp[<i,1>];
		
	forall(i in pres, t in meses: i <=5 && t >= 2)
		x[<i,t>]==d[<i,t>]+dp[<i,t-1>]-dp[<i,t>];
	
	forall(i in pres: i>=6, t in meses) 			//Restriccion 3
		x[<i,t>]==d[<i,t>];
	
	forall(i in pres, t in meses)					//Restriccion 4
	  	x[<i,t>] >= sm[<i,t>];

	forall(k in colab: k==1, t in meses)			//Restriccion 5
	  	sum(i in pres: i<=7)c[<i,k>]*x[<i,k>] <= dtc[<k,t>];
	  	
	forall(k in colab: k==2 || k==3, t in meses)	//Restriccion 6
	  	sum(i in pres: i<=3)c[<i,k>]*x[<i,t>] <= dtc[<k,t>];

	forall(k in colab: k==4, t in meses)			//Restriccion 7
	  	sum(i in pres: i<=8)c[<i,k>]*x[<i,t>] <= dtc[<k,t>];

	forall(k in colab: k==5, t in meses)			//Restriccion 8
	  	sum(i in pres: i>=6 || i<=8) c[<i,k>]*x[<i,t>] <= dtc[<k,t>];
	  
	forall(r in recursos: r==1, t in meses)			//Restriccion 9
		sum(i in pres: i<=3) re[<i,r>]*x[<i,t>] <= dtr[<r,t>];

	forall(i in pres: i==8, r in recursos: r==2, t in meses)	//Restriccion 10
		re[<i,r>]*x[<i,t>] <= dtr[<r,t>];
	
	forall(r in recursos: r==3, t in meses)			//Restriccion 11
		sum(i in pres: i>=4 || i<=7) re[<i,r>]*x[<i,t>] - ex[<r,t>] <= dtr[<r,t>];
	
	forall(r in recursos: r==3, t in meses)			//Restriccion 12
		ex[<r,t>] <= ttex[<r,t>];
	
	forall(r in recursos: r==4, t in meses)			//Restriccion 13
	  	sum(i in pres: i>=6 || i<=8)re[<i,r>]*x[<i,t>] - ex[<r,t>] <= dtr[<r,t>];
	  
	forall(r in recursos: r==4, t in meses)			//Restriccion 14
		ex[<r,t>] <= ttex[<r,t>];
		
	forall(i in pres: i==9, r in recursos: r==5, t in meses)	//Restriccion 15
		re[<i,r>]*x[<i,t>] <= dtr[<r,t>];
		
	forall(r in recursos: r==6, t in meses)			//Restriccion 16
		sum(i in pres: i==4 || i==5)re[<i,r>]*x[<i,t>] <= dtr[<r,t>];
		
	forall(g in medicamentos,t in meses)
	  	sum(i in pres)alpha[<g,i>]*x[<i,t>]==dem[<g,t>]; //Restriccion 17
	  	 
	forall(g in medicamentos,t in meses)  	
		comp[<g,t>]<=compmax[<g,t>]; 				//Restriccion 18
		
	forall(g in medicamentos,t in meses) 			//Restriccion 19
		comp[<g,t>]+compextra[<g,t>]==comptotal[<g,t>];	
	
	forall(t in meses)
	  	sum(g in medicamentos)inv[<g,t>]<=invmax[t]; //Restriccion 20
	  	
	forall (t in meses) 
	 	sum(g in medicamentos)(costinv*inv[<g,t>]+pprove[g]*comp[<g,t>]+pextra[g]*compextra[<g,t>])<=presup;   //Restriccion 21
	 	
	forall (g in medicamentos, t in meses:t>=2)
	  inv[<g,t>]==inv[<g,t-1>]-dem[<g,t>]+comp[<g,t>]+compextra[<g,t>];  //Restriccion 22
	  
	forall (g in medicamentos)
	  inv[<g,1>]==invini[g]-dem[<g,1>]+comp[<g,1>]+compextra[<g,1>];    //Restriccion 23
}