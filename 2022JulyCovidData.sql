--Show Everything to Make Sure Everything Works
SELECT *
FROM PortfolioProject .dbo.CovidDeaths
order by 3,4




--Looking at Total Cases versus Total Deaths (Death per case and its Percentage)
--Shows liklihood of dying if you contract COVID in US
--(IMMUNIZED?!?!)
Select 
	 location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases) * 100 AS death_per_case
FROM PortfolioProject .dbo.CovidDeaths
WHERE location like '%states' AND continent is not null 
ORDER BY 1, 2

--Shows the percentage of total population of people who got COVID within the US
Select 
	 location
	,date
	,population
	,total_cases
	,(total_cases/population) * 100 AS contracted_percent
FROM PortfolioProject .dbo.CovidDeaths
WHERE location like '%states' AND continent is not null 
ORDER BY 1, 2

--Looking at Countries with Highest infection Rate compared to its Population
Select 
	 location
	,population
	,MAX(total_cases) AS HighestInfectionCount
	,MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject .dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Showing Countries with Highest Death Count per Population
Select 
	 location
	,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject .dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continents with Highest Death Count per Population
Select 
	 continent
	,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject .dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Death Percent Tracked Per Day Globally

Select 
	 date
	 ,SUM(new_cases) AS total_new_cases
	 ,SUM(cast(new_deaths as int)) AS total_new_deaths
	 ,SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS death_percent
FROM PortfolioProject .dbo.CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1, 2 

--Total Global Death Percent

Select 
	 SUM(new_cases) AS total_new_cases
	 ,SUM(cast(new_deaths as int)) AS total_new_deaths
	 ,SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS death_percent
FROM PortfolioProject .dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2 



--Look at Total Population vs Vaccinations (How many People Are Vaccinated?)
SELECT 
	 d.continent
	,d.location
	,d.date
	,d.population
	,v.new_vaccinations
	,SUM(cast(v.new_vaccinations as bigint))
		OVER (Partition BY d.location -- Seperates the SUM Operation by Location
		ORDER BY d.location, d.date) AS total_new_vaccinations --Iterates through the dates
	--(total_new_vaccinations / population) * 100 ERROR CANNOT COMPILE SQL CODE ABOVE!!USE CTE!
FROM PortfolioProject ..CovidDeaths d
JOIN PortfolioProject ..CovidVaccinations v
	ON d.location = v.location AND d.date = v.date

--CTE FORMAT
WITH PopvsVac
(
	 continent
	,location
	,date
	,population
	,new_vaccinations
	,total_new_vaccinations
) 
AS
(
SELECT 
	 d.continent
	,d.location
	,d.date
	,d.population
	,v.new_vaccinations
	,SUM(cast(v.new_vaccinations as bigint))
		OVER (Partition BY d.location
		ORDER BY d.location, d.date) AS total_new_vaccinations 
FROM PortfolioProject ..CovidDeaths d
JOIN PortfolioProject ..CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
)

SELECT *, (total_new_vaccinations / population) * 100 AS vaccination_percent
FROM PopvsVac




--TEMP TABLEs
DROP TABLE if exists #PercentPopulationVaccinated --Allow you to alter code
CREATE TABLE #PercentPopulationVaccinated
(
	 continent nvarchar(255)
	,location nvarchar(255)
	,date datetime
	,population numeric
	,new_vaccinations numeric
	,total_new_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	 d.continent
	,d.location
	,d.date
	,d.population
	,v.new_vaccinations
	,SUM(cast(v.new_vaccinations as bigint))
		OVER (Partition BY d.location
		ORDER BY d.location, d.date) AS total_new_vaccinations 
FROM PortfolioProject ..CovidDeaths d
JOIN PortfolioProject ..CovidVaccinations v
	ON d.location = v.location AND d.date = v.date

SELECT *
,(total_new_vaccinations / population) * 100 AS vaccination_percent
FROM #PercentPopulationVaccinated





--Creating View to Store Targeted Data for Visualization Purposes
CREATE View PercentPeopleVaccinated AS
SELECT 
	 d.continent
	,d.location
	,d.date
	,d.population
	,v.new_vaccinations
	,SUM(cast(v.new_vaccinations as bigint))
		OVER (Partition BY d.location
		ORDER BY d.location, d.date) AS total_new_vaccinations
FROM PortfolioProject ..CovidDeaths d
JOIN PortfolioProject ..CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
	WHERE d.continent is not null

--Examine the created View
SELECT *
FROM PercentPeopleVaccinated
