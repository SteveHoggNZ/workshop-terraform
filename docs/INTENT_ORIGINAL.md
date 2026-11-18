Yeah,so we create we need to create theenviron we need to create theenvironment which issegregatedinto dev and productionenvironment andinfrastructure should beina variableor tfvars we can we canmodify thestructuremodify the terraformorinfrastructurein that manner thateasy to deploy uhina differentenvironment

piece ofinfrastructure that'srunninginainaspark data center we wanted to deploy thisinto Azureasa proof of conceptit will bea number of differentservers.<en-US>I haveloadbalances between theservers, but we also want to make sure the terraformco deploymentmatchesourcurrentsort of likestandardsin terms of naming andit will befittingin with some existinginfrastructure that we'veallalready gotinplace

W would be the the existing terrafom and the naming conventions would be theguardrail we would like these to operate under and with the intent that the thiscode should bereusable andit should beas per thestandard we havealready established

 we we want to create oneresourcegroup and to subnet and and one subnet havinga four virtualmachines and other subnet has four virtualmachines which isa backendserver called backend and the backend is behind theas yourloadbalancerso we need to createaresourcesin teleform
