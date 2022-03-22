/*
#### COVID-19 Portfolio Project - SQL data modeling ####
*/

create database PortfolioProject

SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

--SELECT Data that will be in use;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- ##Looking at Total Cases vs Total Deaths##
--Shows the likelihood of dying if you contract COVID-19 in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE LOCATION like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of population contracted COVID-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE LOCATION like '%states%' /*This data is only considering USA */
ORDER BY 1,2

-- Looking at Countries with highest infesction rate compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%' /*This data is only considering USA */
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Shows the countries with highest death count per population 

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%' /*This data is only considering USA */
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENTS


SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%' /*This data is only considering USA */
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest deathcount per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%' /*This data is only considering USA */
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM Popvsvac

-- TEMP TABLE

----- DROP TABLE IF exists #PercentPolulationVaccinated 
-----(if any alerations has to be done or queries run multiple time so that the TEMP tables doesnt have to be delyed manually!)
CREATE TABLE #PercentPolulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPolulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPolulationVaccinated

--- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

select *
from PortfolioProject..CovidDeaths$

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
