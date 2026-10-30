package com.example.calculator;

public record ErrorResponse(int status, String error, String message) {
}
