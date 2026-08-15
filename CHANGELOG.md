# Changelog

Todas as mudanças relevantes deste projeto serão documentadas aqui.

O formato segue a ideia do [Keep a Changelog](https://keepachangelog.com/), com versões em ordem cronológica reversa.

## [r6] - 2026-08-15

### Added
- Adicionado relatório de dependências no `folderstamp`, detectando `stat`, `git`/Gitoxide, `pijul` e `ipfs`.
- Adicionada opção orientada para instalar Git pelo package manager ou Gitoxide via GitHub Releases quando nenhum dos dois está instalado.
- Adicionado suporte a repositórios Pijul ao lado do Git, exibindo canal atual quando `.pijul` existe.
- Adicionada oferta de instalação do Kubo/IPFS via GitHub Releases quando `ipfs` não está instalado.
- Adicionadas sugestões de instalação por package manager para dependências ausentes em Termux, Cygwin, RedoxOS e Linux comum.
- Adicionado `.folderstamp` versionado com o stamp do ambiente atual.
- Criado `to-do.md` organizado a partir do antigo `Tasks.txt`, com novas ideias de portabilidade, documentação e UX.
- Adicionado suporte explícito à detecção de plataforma para Termux, Cygwin e RedoxOS, mantendo compatibilidade com Linux padrão.
- Adicionada saída `Platform:` ao comando `folderstamp display`, facilitando debug em ambientes diferentes.
- Adicionado fallback para detalhes de armazenamento: usa `lsblk` quando disponível e recorre a `df -hP` quando `lsblk` não existe.
- Adicionado fallback para IPFS ausente, exibindo uma mensagem clara quando o comando `ipfs` não está instalado.
- Adicionada seleção automática de diretório de instalação no `install.sh`:
  - Termux: `${PREFIX}/bin` ou `/data/data/com.termux/files/usr/bin`.
  - Cygwin: `/usr/local/bin`.
  - RedoxOS: `${HOME}/bin`.
  - Linux padrão: `/usr/bin`.

### Changed
- Renomeado `Tasks.txt` para `to-do.md`, com checkboxes e seções temáticas.
- Mantida a versão interna do `folderstamp` em `r6`.
- Centralizada a lógica de carimbo de arquivos na função `stamp_path`, reduzindo duplicação entre os modos recursivo e não-recursivo.
- Centralizada a leitura de dados Git na função `print_git_details`, com tratamento para repositórios sem remote configurado.
- O instalador deixou de depender obrigatoriamente de `sudo`; agora usa `sudo` apenas quando o diretório de destino exige permissão elevada e o comando está disponível.
- `folderstamp` e `install.sh` passaram a ser instaláveis/executáveis diretamente, com permissão de execução versionada no Git.

### Fixed
- Evitada falha em ambientes sem `lsblk`, comuns em Termux e outros sistemas minimalistas.
- Evitada falha em ambientes sem `ipfs`, substituindo o erro por uma mensagem informativa.
- Evitada falha ao exibir informações Git quando o repositório não possui remote configurado.
- Evitada dependência rígida de `/usr/bin`, que não é o destino correto em Termux, Cygwin ou RedoxOS.

## [r5] - Antes de 2026-08-15

### Existing
- Exibição do diretório atual.
- Exibição de informações de armazenamento via `lsblk` em Linux.
- Exibição da branch Git atual e primeiro remote quando `.git` existe.
- Suporte aos comandos `display` e `save`.
- Suporte ao modo recursivo com `--recursive` ou `-r`.
- Geração de hash IPFS usando `ipfs add -q --only-hash`.
