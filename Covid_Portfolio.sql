SELECT *
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases VS Total Deaths
-- if you contract covid in VN, you have like around 3% rate to die
SELECT Location, date, total_cases, total_deaths, (convert(float, total_deaths)/convert(float, total_cases))*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Vietnam%'
AND continent is not NULL
ORDER BY 1,2


-- Looking at Total cases VS Population
-- Shows what percentage of population get covid
SELECT Location, date, total_cases, population, (convert(float, total_cases)/ population)*100 as PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE location like '%Vietnam%'
AND continent is not NULL
ORDER BY 1,2

-- Looking at Contries with Highest Infection Rate compare to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, (convert(float, MAX(total_cases))/ population)*100 AS PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Break things down by CONTINENT,	with the highest death count per population 
SELECT continent, MAX(convert(float,total_deaths)) AS TotalDeathsCount
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
GROUP BY continent	
ORDER BY TotalDeathsCount DESC

-- GLOBAL NUMBER
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE new_cases != 0 and new_deaths != 0
ORDER BY 1,2

--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidVaccinations vac
JOIN Portfolio_Project..CovidDeaths dea 
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidVaccinations vac
JOIN Portfolio_Project..CovidDeaths dea 
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidVaccinations vac
JOIN Portfolio_Project..CovidDeaths dea 
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null


SELECT *
FROM #PercentPopulationVaccinated