// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LoanMath {
    uint256 private constant SECONDS_IN_DAY = 1 days;

    function calculateInterest(
        uint256 amount,
        uint256 interestRate,
        uint256 durationInSeconds
    ) internal pure returns (uint256) {
        require(amount > 0, "Importo non valido");
        require(durationInSeconds > 0, "Durata non valida");

        // Converte la durata in giorni
        uint256 durationInDays = durationInSeconds / SECONDS_IN_DAY;

        // Se la durata e' minore di 1 giorno, consideriamo comunque 1 giorno
        if (durationInDays == 0) {
            durationInDays = 1;
        }

        // Formula semplice:
        // interesse = amount * tasso * giorni / (100 * 365)
        return (amount * interestRate * durationInDays) / (100 * 365);
    }

    function calculatePenalty(
        uint256 amount,
        uint256 dueDate,
        uint256 paymentDate
    ) internal pure returns (uint256) {
        if (paymentDate <= dueDate) {
            return 0;
        }

        uint256 daysLate = (paymentDate - dueDate) / SECONDS_IN_DAY;

        // Se anche qui il ritardo e' inferiore a 1 giorno, contiamo almeno 1 giorno
        if (daysLate == 0) {
            daysLate = 1;
        }

        // Penale semplice: 1% dell'importo per ogni giorno di ritardo
        return (amount * daysLate) / 100;
    }
}