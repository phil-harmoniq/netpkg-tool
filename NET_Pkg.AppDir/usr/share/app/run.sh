#! /usr/bin/env bash

A_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dotnet "$A_PATH/DevZH.UI.SimpleSample.dll"
