SELECT *
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..[Covid Vaccinations]
--ORDER BY 3,4;

--SELECT DATA that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid Deaths]
ORDER BY 1,2;

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in USA

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases),6)*100 AS death_as_percentage
FROM PortfolioProject..[Covid Deaths]
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at total vases vs. population
-- Shows what percentage of population contracted covid

SELECT location, date, population,total_cases, (total_cases/population)*100 AS percent_that_contracted
FROM PortfolioProject..[Covid Deaths]
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population,max(total_cases) AS highest_infection_count, max((total_cases/population)) * 100 AS percent_that_contracted
FROM PortfolioProject..[Covid Deaths]
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percent_that_contracted DESC

-- Looking at countries with highest death count per population

SELECT location, max(CAST(total_deaths as int)) as total_death_count
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

SELECT continent, max(CAST(total_deaths as int)) as total_death_count
FROM PortfolioProject..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


-- Global Numbers

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100  as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

SELECT *
FROM PortfolioProject..[Covid Vaccinations]

-- Looking at Total Population vs. Vaccinations

SELECT *
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT TOP(20000)
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as vaccination_running_total,
(/population)*100
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH population_compared_to_vaccination (continent, location, date, population, new_vaccinations, vaccination_running_total)
as
(
SELECT TOP(20000)
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as vaccination_running_total
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (vaccination_running_total/population)*100 as percent_of_pop_vaccinated
FROM population_compared_to_vaccination



-- TEMP TABLE

--DROP TABLE if exists #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
population numeric, 
new_vaccinations numeric,
vaccination_running_total numeric
)

INSERT INTO #percent_population_vaccinated
SELECT TOP(30000)
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as vaccination_running_total
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (vaccination_running_total/population)*100 as percent_of_pop_vaccinated
FROM #percent_population_vaccinated


--Creating View to store data for later (visualizations)

CREATE VIEW percent_population_vaccinated AS
SELECT TOP (30000)
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as vaccination_running_total
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percent_population_vaccinated

