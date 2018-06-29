const assert = require ('assert');              // утверждения
const ganache = require ('ganache-cli');        // тестовая сеть
const Web3 = require ('web3');                  // библиотека для подключения к ефириуму
//const web3 = new Web3(ganache.provider());      // настройка провайдера
//тесты для Roma-v10.sol


require('events').EventEmitter.defaultMaxListeners = 0;


const compiledContract = require('../build/Crowdsale.json');

const compiledToken = require('../build/IGTToken.json');

let accounts;
let contractAddress;
let teamAddress;
//console.log(Date());



describe('Серия тестов ...', () => {
    let web3 = new Web3(ganache.provider());      // настройка провайдера

    it('Разворачиваем контракт для тестирования...', async () => {

        accounts = await web3.eth.getAccounts();
        //    console.log(accounts);
        //    console.log(await web3.eth.getBalance(accounts[0]));
            // получаем контракт из скомпилированного ранее файла .json
        // разворачиваем его в тестовой сети и отправляем транзакцию
        contract = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
            .deploy({ data: compiledContract.bytecode })
            .send({ from: accounts[0], gas: '6000000'});

        //получаем адрес токена
        const tokenAddress = await contract.methods.token().call();

        //получаем развернутый ранее контракт токена по указанному адресу
        token = await new web3.eth.Contract(
        JSON.parse(compiledToken.interface),
        tokenAddress
        );


    });
    

    it('Адрес контракта...', async () => {
        contractAddress = await contract.options.address;
        //console.log(contractAddress);
    });

    it('Проверка баланса контракта...', async () => {
        let cBalance = web3.utils.fromWei(await web3.eth.getBalance(contractAddress), 'ether');
        //console.log("Balance of contract in Ether: ", cBalance);
        assert(cBalance == 0);
    });

    it('Проверка собственника контракта...', async () => {
        const cOwner = await contract.methods.owner().call();
        assert.equal(accounts[0], cOwner);
    });

    it('Устанавливаем менеджером account[2]...', async () => {
        try {
            await contract.methods.setManager(accounts[2]).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Проверка менеджера контракта...', async () => {
        const cManager = await contract.methods.manager().call();
        assert.equal(accounts[2], cManager);
    });

    it('Получаем стадию контракта, по умолчанию это CrowdSale', async () => {
        const myState = await contract.methods.currentState().call();
        assert(myState == 1);
    });

    it('Получаем адрес teamAddress', async () => {
       try {
        teamAddress = await contract.methods.teamAddress().call();
        assert(true)           
        //console.log(teamAddress);
       } catch (error) {
        assert(error);   
       }
    });

    it('Получаем баланс на адресе teamAddress - должно быть 5 250 000', async () => {
        let teamBalance = await token.methods.balanceOf(teamAddress).call();
        assert(teamBalance == 5250000 * (10**18));
    });

    it('Получаем текущий бонус - должен быть 12%', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 12);
        //console.log(bonus);
    });

    it('Переводим токены в кол-ве 1 000 000 на account[2]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[2], 1000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[2] - должно быть 1m + 12%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[2]).call();
        assert(accBalance == 1120000 * (10**18));
        //console.log(accBalance);
    });

    it('Переводим еще токены в кол-ве 1 000 000 на account[2] от учетки менеджера...', async () => {
        try {
            await contract.methods.giveTokens(accounts[2], 1000000).send({
                from: accounts[2],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[2] - должно быть 2m + 12%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[2]).call();
        assert(accBalance == 2240000 * (10**18));
        //console.log(accBalance);
    });
  
    it('Получаем текущий бонус - должен быть 8% т.к. достигнута планка 2 240 000', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 8);
        //console.log(bonus);
    });

    it('Переводим еще токены в кол-ве 1 000 000 на account[3]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[3], 1000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[3] - должно быть 1m + 8%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[3]).call();
        assert(accBalance == 1080000 * (10**18));
        //console.log(accBalance);
    });

    it('Переводим еще токены в кол-ве 1 000 000 на account[3]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[3], 1000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[3] - должно быть 2m + 8%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[3]).call();
        assert(accBalance == 2160000 * (10**18));
        //console.log(accBalance);
    });

    it('Получаем текущий бонус - должен быть 6% т.к. достигнута планка 4 400 000', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 6);
        //console.log(bonus);
    });

    it('Проверяем кол-во проданных токенов - должно быть 4 400 000', async () => {
        let soldTokens = await token.methods.getSoldTokens().call();
        assert(soldTokens == 4400000 * (10**18));
        //console.log(bonus);
    });

    it('Переводим еще токены в кол-ве 2 000 000 на account[4]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[4], 2000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[4] - должно быть 2m + 6%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[4]).call();
        assert(accBalance == 2120000 * (10**18));
        //console.log(accBalance);
    });

    it('Получаем текущий бонус - должен быть 4% т.к. достигнута планка 6 520 000', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 4);
        //console.log(bonus);
    });

    it('Переводим еще токены в кол-ве 2 000 000 на account[5]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[5], 2000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[5] - должно быть 2m + 4%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[5]).call();
        assert(accBalance == 2080000 * (10**18));
        //console.log(accBalance);
    });

    it('Получаем текущий бонус - должен быть 2% т.к. достигнута планка 8 600 000', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 2);
        //console.log(bonus);
    });

    it('Переводим еще токены в кол-ве 2 000 000 на account[6]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[6], 2000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[6] - должно быть 2m + 2%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[6]).call();
        assert(accBalance == 2040000 * (10**18));
        //console.log(accBalance);
    });

    it('Получаем текущий бонус - должен быть 0% т.к. достигнута планка 10 640 000', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 0);
        //console.log(bonus);
    });

    it('Проверяем внешние переводы - по умолчанию заблокированы...', async () => {
        try {
            await token.methods.transfer(accounts[6], 1000).send({
                from: accounts[5],
                gas: "1000000"
            });
            assert(false);    
        } catch (error) {
            assert(error);
            //console.log(error);
        }
    });

    it('Разблокируем внешние переводы...', async () => {
        try {
            await contract.methods.unlockExternalTransfer().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Проверяем внешние переводы - должно работать...', async () => {
        try {
            await token.methods.transfer(accounts[6], 1000).send({
                from: accounts[5],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[6] - должно быть 2m + 2% + 1000', async () => {
        let accBalance = await token.methods.balanceOf(accounts[6]).call();
        assert(accBalance == 2040000000000000000001000);
        //console.log(accBalance);
    });

    it('Блокируем внешние переводы...', async () => {
        try {
            await contract.methods.lockExternalTransfer().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });


    it('Получаем баланс токенов на адресе контракта - должно быть 5 110 000', async () => {
        let teamBalance = await token.methods.balanceOf(contractAddress).call();
        assert(teamBalance == 5110000 * (10**18));
        //console.log(teamBalance);
    });

    it('Возвращаем с teamAddress на баланс контракта 2 млн...', async () => {
        try {
            await contract.methods.returnTokensFromTeamAddress(2000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });  
    
    it('Получаем баланс токенов на адресе teamAddress - должно быть 3 250 000', async () => {
        let teamBalance = await token.methods.balanceOf(teamAddress).call();
        assert(teamBalance == 3250000 * (10**18));
        //console.log(teamBalance);
    });

    it('Получаем баланс токенов на адресе контракта - должно быть 7 110 000', async () => {
        let teamBalance = await token.methods.balanceOf(contractAddress).call();
        assert(teamBalance == 7110000 * (10**18));
        //console.log(teamBalance);
    });

    it('Проверяем кол-во проданных токенов - должно быть 10 640 000', async () => {
        let soldTokens = await token.methods.getSoldTokens().call();
        assert(soldTokens == 10640000 * (10**18));
        //console.log(bonus);
    });

    it('Устанавливаем доп. бонус 5% на 1 день...', async () => {
        try {
            let endTimeBonus = new Date().getTime();
            endTimeBonus = parseInt(endTimeBonus / 1000) +  (3600 * 24);
            await contract.methods.setAddBonus(5, endTimeBonus).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true); 
            //console.log(endTimeBonus);   
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    }); 

    it('Получаем текущий бонус - должен быть 5% ...', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 5);
        //console.log(bonus);
    });


    it('Получаем баланс на адресе accounts[2] - должно быть 2240 000', async () => {
        let accBalance = await token.methods.balanceOf(accounts[2]).call();
        assert(accBalance == 2240000 * (10**18));
        //console.log(accBalance);
    });

    it('Переводим еще токены в кол-ве 1 000 000 на account[2]...', async () => {
        try {
            await contract.methods.giveTokens(accounts[2], 1000000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем баланс на адресе accounts[2] - должно быть 2 240 000 + 1m+5%', async () => {
        let accBalance = await token.methods.balanceOf(accounts[2]).call();
        assert(accBalance == 3290000 * (10**18));
        //console.log(accBalance);
    });

    it('Увеличиваем время на 1 день и 1 час', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 25],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });
    
    it('Получаем текущий бонус - должен быть 0% ...', async () => {
        let bonus = await contract.methods.calcBonus().call();
        assert(bonus == 0);
        //console.log(bonus);
    });

    it('Устанавливаем стадию Migrate- должен отбить, т.к. на teamAddress не ноль токенов...', async () => {
        try {
            await contract.methods.setMigrateStage().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(false);    
        } catch (error) {
            assert(error);
            //console.log(error);
        }
    });

    it('Возвращаем с teamAddress на баланс контракта весь остаток...', async () => {
        try {
            await contract.methods.returnTokensFromTeamAddress(3250000).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });  


    it('Получаем баланс токенов на адресе teamAddress - должен быть ноль ...', async () => {
        let teamBalance = await token.methods.balanceOf(teamAddress).call();
        assert(teamBalance == 0);
        //console.log(teamBalance);
    });

    it('Устанавливаем стадию Migrate...', async () => {
        try {
            await contract.methods.setMigrateStage().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Получаем стадию контракта, должен быть Migrate', async () => {
        const myState = await contract.methods.currentState().call();
        assert(myState == 2);
    });


    it('Возвращаем с accounts[2] на баланс контракта весь остаток...', async () => {
        try {
            let myRetTokens = await token.methods.balanceOf(accounts[2]).call();
            await contract.methods.changeToCoin(accounts[2], myRetTokens).send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    }); 

    it('Получаем баланс токенов на адресе accounts[2] - должен быть 0 ...', async () => {
        let teamBalance = await token.methods.balanceOf(accounts[2]).call();
        assert(teamBalance == 0);
        //console.log(teamBalance);
    });

});
