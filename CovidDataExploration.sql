Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by Location, date

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Italy
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%italy%' and continent is not null
order by Location, date


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%italy%' and continent is not null
order by Location, date


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
Order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Showing Continents with Highest Death Count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by date


-- Looking at Total Population vs Vaccinations
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
)

Select *, (RollingPeoopleVaccinated/Population)*100 as VaccinationPercentage
From PopVsVac

-- using a temporary table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(25),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated

