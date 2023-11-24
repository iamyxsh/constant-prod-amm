// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

error InsufficientFunds();
error WrongToken();
error LiquidityRatioNotSatisfied();
error InsufficientShares();

contract CPAMM {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint public reserveA;
    uint public reserveB;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenA = IERC20(_tokenB);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _to, uint _amount) private {
        balanceOf[_to] -= _amount;
        totalSupply -= _amount;
    }

    function swap(
        address _token,
        uint _amount
    ) external payable returns (uint amount) {
        if (_amount == 0) revert InsufficientFunds();
        bool isTokenA = address(tokenA) == _token;
        bool isTokenB = address(tokenB) == _token;
        if (isTokenA || isTokenB) revert WrongToken();

        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint reserveIn,
            uint reserveOut
        ) = isTokenA
                ? (tokenA, tokenB, reserveA, reserveB)
                : (tokenB, tokenA, reserveB, reserveA);
        tokenIn.transferFrom(msg.sender, address(this), _amount);

        amount = (reserveOut * _amount) / (reserveIn + _amount);

        tokenOut.transfer(msg.sender, amount);

        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));
    }

    function addLiquid(
        uint _amountA,
        uint _amountB
    ) external returns (uint shares) {
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transferFrom(msg.sender, address(this), _amountB);

        if (reserveA > 0 || reserveB > 0) {
            if (!(reserveA * _amountB == reserveA * _amountB))
                revert LiquidityRatioNotSatisfied();
        }

        if (totalSupply == 0) {
            shares = _sqrt(_amountA * _amountB);
        } else {
            shares = _min(
                (_amountA * totalSupply) / reserveA,
                (_amountB * totalSupply) / reserveB
            );
        }

        if (shares == 0) revert LiquidityRatioNotSatisfied();

        _mint(msg.sender, shares);
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));
    }

    function removeLiquidity(
        uint _shares
    ) external returns (uint amount0, uint amount1) {
        uint balanceA = tokenA.balanceOf(address(this));
        uint balanceB = tokenB.balanceOf(address(this));

        amount0 = (_shares * balanceA) / totalSupply;
        amount1 = (_shares * balanceB) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(msg.sender, _shares);
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));

        tokenA.transfer(msg.sender, amount0);
        tokenB.transfer(msg.sender, amount1);
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}
