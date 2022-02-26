
SELECT *
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject#1..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at the total cases vs total deaths and percentage of deaths
-- Likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
WHERE location like '%honduras%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got Covid

SELECT Location, Date, population, total_cases,  (total_cases/population)*100 as PopulationInfected
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1, 2

-- Whate country has the highest infection rate, compared to their population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount
, MAX(total_cases/population)*100 as PercentOfPopulation
FROM PortfolioProject#1..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentOfPopulation desc

-- Whate country has the highest death count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount, 
-- we need to cast the data type as int, 
--currently is varchar --
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break this down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- or this other way

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject#1..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global numbers

SELECT Date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1


--Global summary table

SELECT  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
FROM PortfolioProject#1..CovidDeaths
WHERE continent is not null


-- Lookint at total population vs Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations) )OVER (Partition by dea.Location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject#1..CovidDeaths dea
JOIN PortfolioProject#1..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE --- CTE CTE CTE ----

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric, vac.new_vaccinations) )OVER (Partition by dea.Location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject#1..CovidDeaths dea
JOIN PortfolioProject#1..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 PercentagePeopleVaccinated
FROM PopvsVac


--- USING A TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar (255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(NUMERIC, vac.new_vaccinations) )OVER (Partition by dea.Location 
order by dea.location, dea.date)
FROM PortfolioProject#1..CovidDeaths dea
JOIN PortfolioProject#1..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated




--- Creating view to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(NUMERIC, vac.new_vaccinations))OVER (Partition by dea.Location 
order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject#1..CovidDeaths dea
JOIN PortfolioProject#1..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PortfolioProject#1..PercentPeopleVaccinated