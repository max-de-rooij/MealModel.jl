function SampleData()

  glc = [4.97828626648081	9.83226219754181	6.91736265000290	3.99736583151076	4.74531292225800	5.43827322143290	5.00061029702766	4.90628637452010;
  4.44438211792684	8.56497936784908	5.63459914693781	2.87846029141051	4.38475106119756	4.81819939162605	4.68440337786608	5.03050899831009;
  5.86649175256700	9.76226946026824	6.96041362059030	5.75415042357602	5.49442472724051	6.04402280406414	6.20665742418169	6.05245308331924;
  4.05422828334834	6.68317282007679	5.51316702906051	4.38821628507995	4.08278484538879	4.32903985847918	3.87347487223252	4.14703615153245;
  5.09861020045252	7.19169651136166	6.82073905407388	4.41846994550959	4.35813489280548	5.26064945251012	5.11261281908290	4.95616017748044
  ]
  ins = [21.7542994608033	287.361969174996	294.323541530305	85.4388252908261	18.0684917209633	21.0182483747640	23.1679411923448	21.8618244436204;
  12.5404266739517	124.050624391434	112.050042225095	38.5023639157180	4.04338539971474	13.9239709608373	13.4555353291966	14.3638940482423;
  14.2802823649251	187.522140183945	134.487839622436	29.1762282256049	14.4252356798284	13.8846272694087	14.1392062008499	14.4034973030377;
  19.8623112280412	199.253276210798	258.747486618497	108.466775252880	41.2783085983230	28.2728482488501	22.5314861118322	21.0737318920216;
  108.760022278870	163.060430670949	207.080258023449	185.748135553145	125.786642682319	109.125617637325	104.745417655491	97.2648413826163  
  ]
  trg = [1.16871366007653	1.58440178335270	1.78195011372397	2.39301829368748	2.41622964225137	2.31174933441785	1.93219870120156	1.72103932334563;
  1.12064493587155	0.988185237587493	1.12903104782257	1.27025369534736	1.38325830618782	1.70424182674534	1.74785291292704	1.58034015443830;
  0.934147873129793	0.948495684902739	1.06182083372904	1.19875606178644	1.15075004830806	0.964931259331579	0.959197106220412	0.941575651575427;
  0.911568878711074	0.917659723900865	1.04804850665628	1.06069565177322	1.33975089951343	1.32507244917361	1.25922207558199	0.954325323451108;
  1.25060974085694	1.17562009272981	1.09605143482126	0.948511358144563	1.12086592905305	1.38356985274728	1.74007908698886	1.96096980463590
  ]
  nfa = [0.335735045292724	0.306808022891325	0.175773322340940	0.126453528770619	0.186422309973495	0.317877874980899	0.504623299086489	0.561199670138616;
  0.497614523572355	0.214246896777152	0.0965385883289903	0.0679221665148035	0.210855464643708	0.457945252128255	0.576852516292241	0.515581280746099;
  0.156640771311381	0.0771447415470159	0.0320943309717143	0.0831605186940559	0.189924558213506	0.296184914024023	0.296916721601158	0.215514420118521;
  0.499717860234900	0.311498736265132	0.175340122607563	0.108305580613699	0.127238842499880	0.206930006398300	0.340526704496308	0.388220201643060;
  0.323799139072395	0.297458153444511	0.252292171822141	0.192210379268320	0.192298067008140	0.314571176721740	0.495631829890529	0.471625083527584
  ]

  bwg = [85, 76, 71, 91, 120]
  time = [0.,30.,60.,120.,180.,240.,360.,480.]

  return glc, ins, trg, nfa, bwg, time
end