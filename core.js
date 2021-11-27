import { randomInt } from 'crypto';
import ethers from 'ethers';
import fs from 'fs';
import randomInteger from 'random-int';

// // Call the verifyString function
// let recovered = await contract.verifyString(message, sig.v, sig.r, sig.s);

// console.log(recovered);
// // "0x14791697260E4c9A71f18484C9f997B308e59325"

// deply contract test
// https://rinkeby.etherscan.io/address/0x9F5c13bBC59BC8Db625d589300A1823Bf8147C8a#code

export const setIdentity = async (walletToCheck, amountToMint) => {
	let Identity = {
		// change to true to main sale
		saleLive: true,
		// change all these
		walletKeyPublic: '',
		walletKeyPrivate:
			'',
		contractAddress: '0xeDE41BDA5057F2709a0274FDA26c1638fEd82d3f',
		quickNodeKey:
			'',

		// parameters passed
		walletToCheck: walletToCheck.toString(),
		amountToMint: amountToMint.toString(),
		nonce: randomInt(1, 100000),
		// leave alone
		presaleListPath: './data/whitelist/presale.txt',
		account: null, // connectToWallet()
		jsonOfAbi: null,
		signedMessage: null,
		contractObject: null,
		presaleList: null,
	};

	return Identity;
};

const connectToWallet = async (Identity) => {
	const provider = new ethers.providers.JsonRpcProvider(Identity.quickNodeKey);
	const wallet = new ethers.Wallet(Identity.walletKeyPrivate); // get metamask private key
	const account = wallet.connect(provider);

	return account;
};

const importJsonOfAbi = async (Identity) => {
	let abiToGrab = fs.readFileSync('./data/abi/abi.json', 'utf8');
	// json parse turns to json
	let jsonOfAbi = await JSON.parse(abiToGrab);
	return await jsonOfAbi;
};

const getSignedMessage = async (Identity) => {
	console.log(Identity.walletToCheck, Identity.amountToMint, Identity.nonce);
	let signedMessage = await Identity.account.signMessage(
		ethers.utils.keccak256(2)
	);
	// ethers.utils.keccak256(2)
	// 		Identity.walletToCheck, Identity.amountToMint, Identity.nonce;
	return await signedMessage;
};

const getContractObject = async (Identity) => {
	let contractObjectFlat = new ethers.Contract(
		Identity.contractAddress,
		Identity.jsonOfAbi,
		Identity.account
	);
	// For Solidity, we need the expanded-format of a signature
	let contractObject = ethers.utils.splitSignature(contractObjectFlat);
	return contractObject;
};

const getPresaleList = async (Identity) => {
	let presaleListRaw = fs.readFileSync(Identity.presaleListPath, 'utf8');
	const presaleList = presaleListRaw.split('\n');
	return presaleList;
};

const checkIsAllowToPresaleMint = async (Identity) => {
	let presaleListTimesFound = Identity.presaleList.filter((x) =>
		x.includes(Identity.walletToCheck)
	);
	if (presaleListTimesFound.length > 0) {
		return true;
	} else {
		return false;
	}
};

const removeFromPresaleList = async (Identity) => {
	console.log('->', Identity.PresaleList);
	let updatedPresaleList = Identity.presaleList.filter(
		(e) => e !== Identity.walletToCheck
	);
	fs.writeFileSync(
		'./data/whitelist/presale.txt',
		updatedPresaleList.join('\n')
	);
};

export const mothership = async (walletToCheck, amountToMint) => {
	let Identity = await setIdentity(walletToCheck, amountToMint);
	Identity.account = await connectToWallet(Identity);
	Identity.jsonOfAbi = await importJsonOfAbi(Identity);
	Identity.signedMessage = await getSignedMessage(Identity);
	Identity.presaleList = await getPresaleList(Identity);
	Identity.checkIsAllowToPresaleMint = await checkIsAllowToPresaleMint(
		Identity
	);
	if (Identity.checkIsAllowToPresaleMint) {
		Identity.removeFromPresaleList = await removeFromPresaleList(Identity);
		console.log(Identity.signedMessage);
		console.log('allowed to mint presale');
	} else if (Identity.saleLive) {
		console.log(Identity.signedMessage);
		console.log('allowed to mint sale');
	} else {
		console.log('not allowed to mint');
	}

	//Identity.contractObject = await getContractObject(Identity);
	console.log(Identity.nonce);
	// console.log(Identity.contractObject);
	// console.log(Identity.signedMessage);
	return Identity;
};

mothership(2, '4');
('0xF41D419b73AC92f0f2C2135e798879CE9AB24B63');
