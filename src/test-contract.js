"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var taquito_1 = require("@taquito/taquito");
var signer_1 = require("@taquito/signer");
var contractAddress = "KT1NzAQFhs8PmnHaUK4cdFtvnXdezKvTExBz";
var Tezos = new taquito_1.TezosToolkit('http://127.0.0.1:8732');
Tezos.setProvider({ signer: new signer_1.InMemorySigner('edsk4PDm82iwUPMpsaKCRribzkgRhZCZ7T8CsKBcY25eS2c8tsJeZM') });
// Tout est Promise, nous devons être async
(function () { return __awaiter(void 0, void 0, void 0, function () {
    var contract, _a, _b, _c;
    return __generator(this, function (_d) {
        switch (_d.label) {
            case 0: return [4 /*yield*/, Tezos.contract.at(contractAddress)];
            case 1:
                contract = _d.sent();
                // lecture du storage courant
                _b = (_a = console).log;
                _c = "Read current storage: ";
                return [4 /*yield*/, contract.storage()];
            case 2:
                // lecture du storage courant
                _b.apply(_a, [_c + (_d.sent())]);
                console.log("Update with \"Hello from Taquito\":");
                // Appel de la methode "updateName"
                contract.methods.updateName("from Taquito").send()
                    .then(function (op) {
                    // la transaction est créée, elle attend d'être confirmée
                    console.log("Waiting for " + op.hash + " to be confirmed...");
                    // Après 1 confirmation, nous la considérons comme validée. Nous renvoyons le hash.
                    return op.confirmation(1).then(function () { return op.hash; });
                })
                    .then(function (hash) { return __awaiter(void 0, void 0, void 0, function () {
                    var _a, _b, _c;
                    return __generator(this, function (_d) {
                        switch (_d.label) {
                            case 0:
                                // Le hash de la transaction est obtenu, elle est validée, nous affichons le lien pour l'afficher dans tzstats
                                console.log("Operation injected: https://edo.tzstats.com/" + hash);
                                // Affichage du nouveau storage
                                _b = (_a = console).log;
                                _c = "Read new storage: ";
                                return [4 /*yield*/, contract.storage()];
                            case 1:
                                // Affichage du nouveau storage
                                _b.apply(_a, [_c + (_d.sent())]);
                                return [2 /*return*/];
                        }
                    });
                }); })["catch"](console.error);
                return [2 /*return*/];
        }
    });
}); })()["catch"](function (e) {
    console.log(e);
});
/*
let contract = tezos.contract.at(contractAddress).then( (contract) => {
    console.log(`Read current storage:`);
    contract.storage().then(console.log);
});
*/ 
