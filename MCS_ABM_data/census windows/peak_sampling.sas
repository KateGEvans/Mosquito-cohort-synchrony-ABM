proc glimmix data=fourpeaks METHOD=LAPLACE ;   /*ANOVA with density and litter as class variables */                
nloptions maxiter=100;
     class hatch_interval mort_time mort_percent;
	 model diff = hatch_interval mort_time mort_percent hatch_interval*mort_time hatch_interval*mort_percent
				mort_time*mort_percent hatch_interval*mort_time*mort_percent  /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                           /*the only random effect is residuals*/
	 run; quit;

proc glimmix data=fourpeaks METHOD=LAPLACE ;   /*imported the data from an excel sheet - got mor consistent results*/                
nloptions maxiter=100;
     class treatment;
	 model diff = treatment /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                          /*the only random effect is residuals*/

	estimate 'asynch 10% early' treatment -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% early' treatment -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% early' treatment -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% early' treatment -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% early' treatment -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 10% late' treatment  -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% late' treatment  -1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% late' treatment  -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% late' treatment  -1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% late' treatment  -1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'synch 10% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0; 
	estimate 'synch 25% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 ;
	estimate 'synch 50% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 ;
	estimate 'synch 75% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 ;
	estimate 'synch 90% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 ;
	estimate 'synch 10% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 ;
	estimate 'synch 25% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 1 0 0 0 ;
	estimate 'synch 50% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 ;
	estimate 'synch 75% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 1 0 ;
	estimate 'synch 90% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 1 ;
	 run; quit;

	 proc glimmix data=shortpeak METHOD=LAPLACE ;   /*ANOVA with density and litter as class variables */                
nloptions maxiter=100;
     class hatch_interval mort_time mort_percent;
	 model diff = hatch_interval mort_time mort_percent hatch_interval*mort_time hatch_interval*mort_percent
				mort_time*mort_percent hatch_interval*mort_time*mort_percent  /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                           /*the only random effect is residuals*/
	 run; quit;

proc glimmix data=shortpeak METHOD=LAPLACE ;   /*imported the data from an excel sheet - got mor consistent results*/                
nloptions maxiter=100;
     class treatment;
	 model diff = treatment /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                          /*the only random effect is residuals*/

	estimate 'asynch 10% early' treatment -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% early' treatment -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% early' treatment -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% early' treatment -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% early' treatment -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 10% late' treatment  -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% late' treatment  -1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% late' treatment  -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% late' treatment  -1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% late' treatment  -1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'synch 10% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0; 
	estimate 'synch 25% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 ;
	estimate 'synch 50% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 ;
	estimate 'synch 75% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 ;
	estimate 'synch 90% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 ;
	estimate 'synch 10% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 ;
	estimate 'synch 25% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 1 0 0 0 ;
	estimate 'synch 50% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 ;
	estimate 'synch 75% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 1 0 ;
	estimate 'synch 90% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 1 ;
	 run; quit;


proc glimmix data=tallpeak METHOD=LAPLACE ;   /*ANOVA with density and litter as class variables */                
nloptions maxiter=100;
     class hatch_interval mort_time mort_percent;
	 model diff = hatch_interval mort_time mort_percent hatch_interval*mort_time hatch_interval*mort_percent
				mort_time*mort_percent hatch_interval*mort_time*mort_percent  /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                           /*the only random effect is residuals*/
	 run; quit;

proc glimmix data=tallpeak METHOD=LAPLACE ;   /*imported the data from an excel sheet - got mor consistent results*/                
nloptions maxiter=100;
     class treatment;
	 model diff = treatment /**/ / ddfm=bw dist=t;   /* poisson distribution of error*/
	 random _residual_;                                                          /*the only random effect is residuals*/

	estimate 'asynch 10% early' treatment -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% early' treatment -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% early' treatment -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% early' treatment -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% early' treatment -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 10% late' treatment  -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 25% late' treatment  -1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 50% late' treatment  -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 75% late' treatment  -1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'asynch 90% late' treatment  -1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
	estimate 'synch 10% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0; 
	estimate 'synch 25% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 ;
	estimate 'synch 50% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 ;
	estimate 'synch 75% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 ;
	estimate 'synch 90% early' treatment   0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 ;
	estimate 'synch 10% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 ;
	estimate 'synch 25% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 1 0 0 0 ;
	estimate 'synch 50% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 ;
	estimate 'synch 75% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 1 0 ;
	estimate 'synch 90% late' treatment    0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 1 ;
	 run; quit;

