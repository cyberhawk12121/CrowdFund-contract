const CrowdFund= artifacts.require('CrowdFund');

module.exports= async function(deployer){
    deployer.deploy(CrowdFund);
}