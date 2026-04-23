// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LoanMath.sol";

contract LoanManager {
    using LoanMath for uint256;

    address public admin;
    uint256 public loanCounter;

    enum Status {
        Active,
        Paid,
        Overdue,
        Cancelled
    }

    struct Loan {
        uint256 id;
        address lender;
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 duration;
        uint256 startDate;
        uint256 endDate;
        Status status;
    }

    mapping(uint256 => Loan) public loans;

    event LoanCreated(
        uint256 indexed loanId,
        address indexed lender,
        uint256 amount,
        uint256 interestRate,
        uint256 duration
    );

    event LoanTaken(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 startDate,
        uint256 endDate
    );

    event LoanRepaid(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 totalPaid,
        uint256 interestPaid,
        uint256 penaltyPaid
    );

    event LoanCancelled(uint256 indexed loanId);
    event LoanMarkedOverdue(uint256 indexed loanId);
    event LoanStatusUpdated(uint256 indexed loanId, Status newStatus);
    event AdminTransferred(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Solo admin");
        _;
    }

    modifier loanExists(uint256 loanId) {
        require(loanId > 0 && loanId <= loanCounter, "Prestito inesistente");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Nuovo admin non valido");

        address oldAdmin = admin;
        admin = newAdmin;

        emit AdminTransferred(oldAdmin, newAdmin);
    }

    function createLoanOffer(
        uint256 interestRate,
        uint256 duration
    ) external payable {
        require(msg.value > 0, "Devi inviare dei fondi");
        require(duration > 0, "Durata non valida");

        loanCounter++;

        loans[loanCounter] = Loan({
            id: loanCounter,
            lender: msg.sender,
            borrower: address(0),
            amount: msg.value,
            interestRate: interestRate,
            duration: duration,
            startDate: 0,
            endDate: 0,
            status: Status.Active
        });

        emit LoanCreated(
            loanCounter,
            msg.sender,
            msg.value,
            interestRate,
            duration
        );
    }

    function takeLoan(uint256 loanId) external loanExists(loanId) {
        Loan storage loan = loans[loanId];

        require(loan.status == Status.Active, "Prestito non disponibile");
        require(loan.borrower == address(0), "Prestito gia assegnato");
        require(msg.sender != loan.lender, "Il lender non puo prendere il proprio prestito");

        // EFFECTS
        loan.borrower = msg.sender;
        loan.startDate = block.timestamp;
        loan.endDate = block.timestamp + loan.duration;

        // INTERACTIONS
        payable(loan.borrower).transfer(loan.amount);

        emit LoanTaken(loanId, msg.sender, loan.startDate, loan.endDate);
    }

    function repayLoan(uint256 loanId) external payable loanExists(loanId) {
        Loan storage loan = loans[loanId];

        require(loan.borrower != address(0), "Prestito non ancora preso");
        require(msg.sender == loan.borrower, "Non sei il borrower");
        require(
            loan.status == Status.Active || loan.status == Status.Overdue,
            "Prestito non ripagabile"
        );

        uint256 interest = LoanMath.calculateInterest(
            loan.amount,
            loan.interestRate,
            loan.duration
        );

        uint256 penalty = LoanMath.calculatePenalty(
            loan.amount,
            loan.endDate,
            block.timestamp
        );

        uint256 totalToPay = loan.amount + interest + penalty;

       
        require(msg.value >= totalToPay, "Importo insufficiente");

        uint256 refund = msg.value - totalToPay;

        loan.status = Status.Paid;

        // INTERACTIONS
        payable(loan.lender).transfer(totalToPay);

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        emit LoanRepaid(loanId, msg.sender, totalToPay, interest, penalty);
    }

    function cancelLoan(uint256 loanId) external loanExists(loanId) {
        Loan storage loan = loans[loanId];

        require(msg.sender == loan.lender, "Solo il lender puo annullare");
        require(loan.status == Status.Active, "Prestito non attivo");
        require(loan.borrower == address(0), "Prestito gia preso");

        // EFFECTS
        loan.status = Status.Cancelled;

        // INTERACTIONS
        payable(loan.lender).transfer(loan.amount);

        emit LoanCancelled(loanId);
    }

    function checkOverdue(uint256 loanId) external loanExists(loanId) {
        Loan storage loan = loans[loanId];

        require(loan.borrower != address(0), "Prestito non ancora assegnato");

        if (
            block.timestamp > loan.endDate &&
            loan.status == Status.Active
        ) {
            loan.status = Status.Overdue;
            emit LoanMarkedOverdue(loanId);
        }
    }

    function updateStatus(
        uint256 loanId,
        Status newStatus
    ) external onlyAdmin loanExists(loanId) {
        loans[loanId].status = newStatus;
        emit LoanStatusUpdated(loanId, newStatus);
    }

    function getLoan(
        uint256 loanId
    )
        external
        view
        loanExists(loanId)
        returns (
            uint256 id,
            address lender,
            address borrower,
            uint256 amount,
            uint256 interestRate,
            uint256 duration,
            uint256 startDate,
            uint256 endDate,
            Status status
        )
    {
        Loan memory loan = loans[loanId];

        return (
            loan.id,
            loan.lender,
            loan.borrower,
            loan.amount,
            loan.interestRate,
            loan.duration,
            loan.startDate,
            loan.endDate,
            loan.status
        );
    }

    function getTotalAmountToRepay(
        uint256 loanId
    )
        external
        view
        loanExists(loanId)
        returns (
            uint256 principal,
            uint256 interest,
            uint256 penalty,
            uint256 total
        )
    {
        Loan memory loan = loans[loanId];

        require(loan.borrower != address(0), "Prestito non ancora preso");

        interest = LoanMath.calculateInterest(
            loan.amount,
            loan.interestRate,
            loan.duration
        );

        penalty = LoanMath.calculatePenalty(
            loan.amount,
            loan.endDate,
            block.timestamp
        );

        total = loan.amount + interest + penalty;

        return (loan.amount, interest, penalty, total);
    }
}