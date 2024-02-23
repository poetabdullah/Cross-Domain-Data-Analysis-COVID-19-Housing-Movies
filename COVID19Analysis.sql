SELECT * FROM PortfolioProject..CovidDeaths ORDER BY 3,4;

SELECT * FROM PortfolioProject..CovidVaccinations ORDER BY 3,4;

-- Selecting the data that we are now going to use:
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Total cases vs total deaths: Shows us the percentage of the population that has COVID-19 in countries that spell like pak
SELECT location, date, total_cases, population,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths  WHERE location like '%pak%' and continent is not null ORDER BY 1,2;


-- Countries with the highest infection rate as per population:
SELECT location, population, MAX(Total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 
AS affectedPopulation FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP BY location, population ORDER BY 
affectedPopulation DESC;

-- Countries with the highest death count per population:
-- Since these are COVID cases, we are selecting maximum value of the total deaths since that is the current
-- most death value, and obviously deaths increase with the passage of time.
-- Also, since the total_deaths is of nvarchar type, we need it to convert it into int.
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount FROM PortfolioProject..CovidDeaths 
GROUP BY location ORDER BY TotalDeathCount DESC;

-- We see in our above data that there are continents being displayed in locations, which we don't really 
--want.
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount FROM PortfolioProject..CovidDeaths 
WHERE continent is not null GROUP BY location ORDER BY TotalDeathCount DESC;

-- Data as per continents:
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL GROUP BY continent ORDER BY 
TotalDeathCount DESC;

-- Total global cases & deaths by date:
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, 
(SUM(CAST(new_deaths as int)) / SUM(new_cases)) * 100 AS DeathPercentage FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL GROUP BY date ORDER BY 1, 2;

-- Overall global cases and deaths:
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, 
(SUM(CAST(new_deaths as int)) / SUM(new_cases)) * 100 AS DeathPercentage FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL ORDER BY 1, 2;

-- Total populations vs vaccinations:
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) 
AS TotalCurrentVaccinated
--, (RollingPeopleVaccinated / d.population) * 100 AS VaccinationRatePercentage
FROM PortfolioProject..CovidDeaths d JOIN PortfolioProject..CovidVaccinations v ON d.location = 
v.location AND d.date = v.date WHERE d.continent IS NOT NULL 
ORDER BY 2, 3;


-- Using CTE:
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalCurrentVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
AS TotalCurrentVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (TotalCurrentVaccinated/Population)*100 AS VaccinatedPercentage FROM PopvsVac;


-- Temp tables:
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(continent nvarchar(255), location nvarchar(255), date datetime, 
population numeric, new_vaccinations numeric, TotalCurrentVaccinated numeric);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
AS TotalCurrentVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (TotalCurrentVaccinated/Population)*100 AS VaccinatedPercentage FROM #PercentPopulationVaccinated;


-- Views for data visualization:
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
AS TotalCurrentVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date;

SELECT * FROM PercentPopulationVaccinated;


CREATE VIEW CountryCovidStats AS
SELECT d.date,d.total_cases,d.new_cases,d.total_deaths,v.new_vaccinations
FROM PortfolioProject..CovidDeaths d JOIN PortfolioProject..CovidVaccinations v 
ON d.location = v.location AND d.date = v.date WHERE d.location = 'Pakistan';

SELECT * FROM CountryCovidStats;